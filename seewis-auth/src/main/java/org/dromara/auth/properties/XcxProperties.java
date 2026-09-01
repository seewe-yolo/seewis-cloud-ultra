package org.dromara.auth.properties;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.cloud.context.config.annotation.RefreshScope;
import org.springframework.context.annotation.Configuration;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 小程序登录配置
 *
 * @author seewis
 */
@Data
@Configuration
@RefreshScope
@ConfigurationProperties(prefix = "security.xcx")
public class XcxProperties {

    /**
     * 小程序 appid 与密钥映射，key 为 appid，value 为 appSecret，支持配置多个小程序
     */
    private Map<String, String> apps = new LinkedHashMap<>();

}
