package org.dromara.auth.form;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.core.domain.model.LoginBody;

/**
 * 三方登录对象
 *
 * @author Lion Li
 */
@Data
@EqualsAndHashCode(callSuper = true)
public class XcxLoginBody extends LoginBody {

    /**
     * 小程序id(多个小程序时使用)
     */
    private String appid;

    /**
     * 小程序code
     */
    @NotBlank(message = "{xcx.code.not.blank}")
    private String xcxCode;

    /**
     * 手机号一键登录 code（button open-type="getPhoneNumber" 获取），首次登录自动注册时必传
     */
    private String phoneCode;

}
