package org.dromara.auth.service.impl;

import cn.dev33.satoken.stp.StpUtil;
import cn.dev33.satoken.stp.parameter.SaLoginParameter;
import cn.hutool.http.HttpUtil;
import cn.hutool.json.JSONObject;
import cn.hutool.json.JSONUtil;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import me.zhyd.oauth.config.AuthConfig;
import me.zhyd.oauth.model.AuthCallback;
import me.zhyd.oauth.model.AuthResponse;
import me.zhyd.oauth.model.AuthToken;
import me.zhyd.oauth.model.AuthUser;
import me.zhyd.oauth.request.AuthRequest;
import me.zhyd.oauth.request.AuthWechatMiniProgramRequest;
import org.apache.dubbo.config.annotation.DubboReference;
import org.dromara.auth.domain.vo.LoginVo;
import org.dromara.auth.form.XcxLoginBody;
import org.dromara.auth.properties.XcxProperties;
import org.dromara.auth.service.IAuthStrategy;
import org.dromara.auth.service.SysLoginService;
import org.dromara.common.core.exception.ServiceException;
import org.dromara.common.core.constant.GlobalConstants;
import org.dromara.common.core.utils.ValidatorUtils;
import org.dromara.common.core.utils.StringUtils;
import org.dromara.common.json.utils.JsonUtils;
import org.dromara.common.redis.utils.RedisUtils;
import org.dromara.common.satoken.utils.LoginHelper;
import org.dromara.system.api.RemoteConfigService;
import org.dromara.system.api.RemoteUserService;
import org.dromara.system.api.domain.vo.RemoteClientVo;
import org.dromara.system.api.model.XcxLoginUser;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 邮件认证策略
 *
 * @author Michelle.Chung
 */
@Slf4j
@Service("xcx" + IAuthStrategy.BASE_NAME)
@RequiredArgsConstructor
public class XcxAuthStrategy implements IAuthStrategy {

    private final SysLoginService loginService;
    private final XcxProperties xcxProperties;

    @DubboReference
    private final RemoteConfigService remoteConfigService;

    @DubboReference
    private RemoteUserService remoteUserService;

    @Override
    public LoginVo login(String body, RemoteClientVo client) {
        XcxLoginBody loginBody = JsonUtils.parseObject(body, XcxLoginBody.class);
        ValidatorUtils.validate(loginBody);
        // xcxCode 为 小程序调用 wx.login 授权后获取
        String xcxCode = loginBody.getXcxCode();
        // 多个小程序识别使用
        String appid = loginBody.getAppid();
        // 手机号一键登录 code（button open-type="getPhoneNumber" 获取），首次登录自动注册时需要
        String phoneCode = loginBody.getPhoneCode();

        Map<String, String> apps = loadApps();
        String useAppid = resolveAppid(apps, appid);
        String appSecret = resolveAppSecret(apps, useAppid);

        // 校验 appid + appsrcret + xcxCode 调用登录凭证校验接口 获取 session_key 与 openid
        AuthRequest authRequest = new AuthWechatMiniProgramRequest(AuthConfig.builder()
            .clientId(useAppid).clientSecret(appSecret)
            .ignoreCheckRedirectUri(true).ignoreCheckState(true).build());
        AuthCallback authCallback = new AuthCallback();
        authCallback.setCode(xcxCode);
        AuthResponse<AuthUser> resp = authRequest.login(authCallback);
        String openid, unionId;
        if (resp.ok()) {
            AuthToken token = resp.getData().getToken();
            openid = token.getOpenId();
            // 微信小程序只有关联到微信开放平台下之后才能获取到 unionId，因此unionId不一定能返回。
            unionId = token.getUnionId();
        } else {
            throw new ServiceException(resp.getMsg());
        }
        // 手机号一键登录：获取用户授权的真实手机号，首次登录自动注册时作为账号
        String phone = null;
        if (StringUtils.isNotBlank(phoneCode)) {
            phone = getPhoneNumber(useAppid, appSecret, phoneCode);
        }
        // todo getUserInfoByOpenid 方法内部查询逻辑需要自行根据业务实现
        XcxLoginUser loginUser = remoteUserService.getUserInfoByOpenid(openid, phone);
        loginUser.setClientKey(client.getClientKey());
        loginUser.setDeviceType(client.getDeviceType());

        SaLoginParameter model = IAuthStrategy.buildLoginParameter(client);
        // 生成token
        LoginHelper.login(loginUser, model);

        LoginVo loginVo = new LoginVo();
        loginVo.setAccessToken(StpUtil.getTokenValue());
        loginVo.setExpireIn(StpUtil.getTokenTimeout());
        loginVo.setClientId(client.getClientId());
        loginVo.setOpenid(openid);
        return loginVo;
    }

    /**
     * 加载小程序配置：优先取参数管理中的 sys.account.xcxApps（JSON 数组），未配置时回退 yml 配置
     */
    private Map<String, String> loadApps() {
        String configValue = remoteConfigService.getConfigValue("sys.account.xcxApps");
        if (StringUtils.isNotBlank(configValue)) {
            try {
                Map<String, String> apps = new LinkedHashMap<>();
                for (XcxApp app : JsonUtils.parseArray(configValue, XcxApp.class)) {
                    if (StringUtils.isNotBlank(app.getAppid()) && StringUtils.isNotBlank(app.getAppSecret())) {
                        apps.put(app.getAppid(), app.getAppSecret());
                    }
                }
                if (!apps.isEmpty()) {
                    return apps;
                }
            } catch (Exception e) {
                log.warn("解析参数 sys.account.xcxApps 失败，回退使用 yml 配置 security.xcx.apps", e);
            }
        }
        return xcxProperties.getApps();
    }

    /**
     * 解析实际使用的 appid：未传且仅配置了一个小程序时自动使用唯一配置
     */
    private String resolveAppid(Map<String, String> apps, String appid) {
        if (StringUtils.isNotBlank(appid)) {
            return appid;
        }
        if (apps.size() == 1) {
            return apps.keySet().iterator().next();
        }
        throw new ServiceException("未配置小程序 appid，请在参数 sys.account.xcxApps 或 security.xcx.apps 中配置");
    }

    /**
     * 解析小程序密钥
     */
    private String resolveAppSecret(Map<String, String> apps, String appid) {
        String secret = apps.get(appid);
        if (StringUtils.isBlank(secret)) {
            throw new ServiceException("未配置小程序 " + appid + " 对应的密钥，请在参数 sys.account.xcxApps 中配置");
        }
        return secret;
    }

    /**
     * 手机号一键登录：调用微信 getuserphonenumber 接口获取用户授权的真实手机号
     */
    private String getPhoneNumber(String appid, String appSecret, String phoneCode) {
        String accessToken = getAccessToken(appid, appSecret);
        JSONObject body = new JSONObject();
        body.set("code", phoneCode);
        String response = HttpUtil.post(
            "https://api.weixin.qq.com/wxa/business/getuserphonenumber?access_token=" + accessToken,
            body.toString());
        JSONObject json = JSONUtil.parseObj(response);
        if (json.getInt("errcode", 0) != 0) {
            log.warn("微信手机号获取失败: {}", response);
            throw new ServiceException("手机号获取失败: " + json.getStr("errmsg"));
        }
        return json.getJSONObject("phone_info").getStr("purePhoneNumber");
    }

    /**
     * 获取微信接口调用凭证 stable_token，缓存至 redis，过期前 5 分钟刷新
     */
    private String getAccessToken(String appid, String appSecret) {
        String cacheKey = GlobalConstants.GLOBAL_REDIS_KEY + "xcx:access_token:" + appid;
        String accessToken = RedisUtils.getCacheObject(cacheKey);
        if (StringUtils.isNotBlank(accessToken)) {
            return accessToken;
        }
        JSONObject body = new JSONObject();
        body.set("grant_type", "client_credential");
        body.set("appid", appid);
        body.set("secret", appSecret);
        String response = HttpUtil.post("https://api.weixin.qq.com/cgi-bin/stable_token", body.toString());
        JSONObject json = JSONUtil.parseObj(response);
        if (json.getInt("errcode", 0) != 0) {
            log.warn("微信 access_token 获取失败: {}", response);
            throw new ServiceException("微信凭证获取失败: " + json.getStr("errmsg"));
        }
        accessToken = json.getStr("access_token");
        RedisUtils.setCacheObject(cacheKey, accessToken,
            Duration.ofSeconds(json.getInt("expires_in", 7200) - 300));
        return accessToken;
    }

    /**
     * 参数 sys.account.xcxApps 的 JSON 元素结构
     */
    @Data
    public static class XcxApp {
        private String appid;
        private String appSecret;
    }

}
