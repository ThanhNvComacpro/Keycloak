<!DOCTYPE html>
<html lang="${locale}">
<head>
    <meta charset="utf-8">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="robots" content="noindex, nofollow">
    <title>${msg("otpVerify.title")}</title>
    <link rel="icon" href="${url.resourcesPath}/img/favicon.ico" />
    <#if properties.stylesCommon?has_content>
        <#list properties.stylesCommon?split(' ') as style>
            <link href="${url.resourcesCommonPath}/${style}" rel="stylesheet" />
        </#list>
    </#if>
    <#if properties.styles?has_content>
        <#list properties.styles?split(' ') as style>
            <link href="${url.resourcesPath}/${style}" rel="stylesheet" />
        </#list>
    </#if>
    <#if properties.scripts?has_content>
        <#list properties.scripts?split(' ') as script>
            <script src="${url.resourcesPath}/${script}" type="text/javascript"></script>
        </#list>
    </#if>
    <#if scripts??>
        <#list scripts as script>
            <script src="${script}" type="text/javascript"></script>
        </#list>
    </#if>
</head>

<body class="${properties.kcBodyClass!}">
<div class="${properties.kcLoginClass!}">
    <div id="kc-header" class="${properties.kcHeaderClass!}">
        <div id="kc-header-wrapper"
             class="${properties.kcHeaderWrapperClass!}">${kcSanitize(msg("loginTitleHtml",(realm.displayNameHtml!'')))?no_esc}</div>
    </div>
    <div class="${properties.kcFormCardClass!}">
        <header class="${properties.kcFormHeaderClass!}">
            <#if realm.internationalizationEnabled  && locale.supported?size gt 1>
                <div class="${properties.kcLocaleMainClass!}" id="kc-locale">
                    <div id="kc-locale-wrapper" class="${properties.kcLocaleWrapperClass!}">
                        <div id="kc-locale-dropdown" class="${properties.kcLocaleDropDownClass!}">
                            <a href="#" id="kc-current-locale-link">${locale.current}</a>
                            <ul class="${properties.kcLocaleListClass!}">
                                <#list locale.supported as l>
                                    <li class="${properties.kcLocaleListItemClass!}">
                                        <a class="${properties.kcLocaleItemClass!}" href="${l.url}">${l.label}</a>
                                    </li>
                                </#list>
                            </ul>
                        </div>
                    </div>
                </div>
            </#if>
            <h1 id="kc-page-title">${msg("otpVerify.title")}</h1>
        </header>
        <div id="kc-content">
            <div id="kc-content-wrapper">

                <#-- Display errors -->
                <#if displayRequiredFields>
                    <div class="${properties.kcLabelWrapperClass!}">
                        <span class="${properties.kcLabelClass!}">${msg("requiredFields")}</span>
                    </div>
                </#if>

                <#if displayMessage && message?has_content && (message.type != 'warning' || !isAppInitiatedAction??)>
                    <div class="alert-${message.type} ${properties.kcAlertClass!} pf-m-<#if message.type = 'error'>danger<#else>${message.type}</#if>">
                        <div class="pf-c-alert__icon">
                            <#if message.type = 'success'><span class="${properties.kcFeedbackSuccessIcon!}"></span></#if>
                            <#if message.type = 'warning'><span class="${properties.kcFeedbackWarningIcon!}"></span></#if>
                            <#if message.type = 'error'><span class="${properties.kcFeedbackErrorIcon!}"></span></#if>
                            <#if message.type = 'info'><span class="${properties.kcFeedbackInfoIcon!}"></span></#if>
                        </div>
                        <span class="${properties.kcAlertTitleClass!}">${kcSanitize(message.summary)?no_esc}</span>
                    </div>
                </#if>

                <div class="${properties.kcFormGroupClass!}">
                    <div class="${properties.kcInputHelperTextClass!}" style="margin-bottom: 20px;">
                        <#if otpType == "email">
                            ${msg("otpVerify.emailSentInfo", contact!"")}
                        <#else>
                            ${msg("otpVerify.smsSentInfo", contact!"")}
                        </#if>
                    </div>
                </div>

                <form id="kc-otp-verify-form" class="${properties.kcFormClass!}" action="${url.loginAction}" method="post">
                    <div class="${properties.kcFormGroupClass!}">
                        <label for="otp" class="${properties.kcLabelClass!}">${msg("otpVerify.codeLabel")}</label>
                        <input type="text" id="otp" name="otp" class="${properties.kcInputClass!}" 
                               placeholder="${msg("otpVerify.codePlaceholder")}" autofocus 
                               autocomplete="off" maxlength="6" pattern="[0-9]{6}" required />
                        <div class="${properties.kcInputHelperTextClass!}">
                            ${msg("otpVerify.codeHelp", validityMinutes!5)}
                        </div>
                    </div>

                    <div id="kc-form-options">
                        <div class="${properties.kcFormOptionsWrapperClass!}">
                        </div>
                    </div>

                    <div id="kc-form-buttons" class="${properties.kcFormButtonsClass!}">
                        <input type="hidden" name="action" value="verify-otp"/>
                        <input class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonBlockClass!} ${properties.kcButtonLargeClass!}" 
                               name="submit" id="kc-verify" type="submit" value="${msg("otpVerify.verifyButton")}"/>
                    </div>
                </form>

                <div id="kc-info" class="${properties.kcSignUpClass!}">
                    <div id="kc-info-wrapper" class="${properties.kcInfoAreaWrapperClass!}">
                        <p>
                            <a href="${url.loginAction}?action=back" class="${properties.kcButtonClass!} ${properties.kcButtonDefaultClass!}">
                                ${msg("otpVerify.backButton")}
                            </a>
                        </p>
                    </div>
                </div>

            </div>
        </div>
    </div>
</div>

<script>
// Auto-focus on OTP input and format input
document.addEventListener('DOMContentLoaded', function() {
    var otpInput = document.getElementById('otp');
    if (otpInput) {
        otpInput.focus();
        
        // Format input to show only numbers
        otpInput.addEventListener('input', function(e) {
            var value = e.target.value.replace(/[^0-9]/g, '');
            e.target.value = value;
            
            // Auto-submit when 6 digits entered
            if (value.length === 6) {
                setTimeout(function() {
                    document.getElementById('kc-otp-verify-form').submit();
                }, 100);
            }
        });
        
        // Prevent pasting non-numeric content
        otpInput.addEventListener('paste', function(e) {
            e.preventDefault();
            var paste = (e.clipboardData || window.clipboardData).getData('text');
            var numericPaste = paste.replace(/[^0-9]/g, '').substring(0, 6);
            e.target.value = numericPaste;
            
            if (numericPaste.length === 6) {
                setTimeout(function() {
                    document.getElementById('kc-otp-verify-form').submit();
                }, 100);
            }
        });
    }
});
</script>

</body>
</html>
