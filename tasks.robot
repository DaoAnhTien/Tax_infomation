*** Settings ***
Documentation       Template robot main suite.

Library             DOP.RPA.ProcessArgument
Library             DOP.RPA.Asset
Library             DOP.RPA.Log
Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             libraries/GdtCapcha.py
Library             RPA.PDF
Library             RPA.FileSystem
Library             RPA.JSON
Library             RPA.Tables


*** Tasks ***
Tax infomation
    Look up taxpayer information
    output results


*** Keywords ***
Look up taxpayer information
    ${TAX_WEB}=    Get In Arg    webTax
    ${TAX_WEB_PATH}=    Set Variable    ${TAX_WEB}[value]
    ${MAX_RETRY}=    Get In Arg    maxretry
    Open Available Browser    ${TAX_WEB_PATH}
    ${TAX_CODE}=    Get In Arg    orgTaxCode
    ${TAX_CODE_IFO}=    Set Variable    ${TAX_CODE}[value]
    Input Text    mst    ${TAX_CODE_IFO}
    ${RESULT}=    Set Variable    False
    FOR    ${i}    IN RANGE    ${MAX_RETRY}[value]
        Fill Capcha checks
        ${RESULT}=    Run keyword And Return Status
        ...    Wait Until Element Is Visible
        ...    //table[@class="ta_border"]
        ...    timeout=1
        IF    ${RESULT}    BREAK
    END

Fill Capcha checks
    Screenshot
    ...    //*[@id="tcmst"]/form/table/tbody/tr[6]/td[2]/table/tbody/tr/td[2]/div/img
    ...    ${OUTPUT_DIR}${/}Capcha.png
    ${GETCAPTCHA}=    Resolve Captcha    ${OUTPUT_DIR}${/}Capcha.png    dop.vbpo-st.com
    ${CAPTCHA_VALID}=    Is Captcha Valid    ${GETCAPTCHA}
    IF    not ${CAPTCHA_VALID}
        ${GETCAPTCHA}=    Set Variable    None
    END
    Log To Console    \nResolved Captcha: ${GETCAPTCHA}\n
    Input Text    //input[@name="captcha"]    ${GETCAPTCHA}
    Click Button    //input[@class="subBtn"]

output results
    Click Element    //*[@id="tcmst"]/table/tbody/tr[2]/td[3]/a/b
    ${JSON}=    Convert String to JSON    {"TaxCode":"" ,"name":"" ,"address":"" ,"date":""}
    ${Tax_Code}=    Get Text    //*[@id="tcmst"]/table/tbody/tr[1]/td[1]
    ${name}=    Get Text    //*[@id="tcmst"]/table/tbody/tr[2]/td[1]
    ${address}=    Get Text    //*[@id="tcmst"]/table/tbody/tr[4]/td
    ${date}=    Get Text    //*[@id="tcmst"]/table/tbody/tr[1]/td[2]
    ${coords}=    Create Dictionary    latitude=13.1234    longitude=130.1234
    ${JSON}=    Update value to JSON    ${JSON}    TaxCode    ${Tax_Code}
    ${JSON}=    Update value to JSON    ${JSON}    name    ${name}
    ${JSON}=    Update value to JSON    ${JSON}    address    ${address}
    ${JSON}=    Update value to JSON    ${JSON}    date    ${date}
    Log To Console    ${JSON}
    Set Out Arg    OutputData    ${JSON}
