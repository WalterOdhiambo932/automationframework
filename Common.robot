*** Settings ***
Library  JSONLibrary
Library  RequestsLibrary
Library  Collections
Library  SeleniumLibrary
#Library  JsonValidator
Library  OperatingSystem
Library   ../../Library/JsonExtender.py
Library   ../../Library/stringToDict.py
Library   ../../Library/cert.py
#Library   ../../Library/UUID.py
Library  urllib3
Library  String
Library  DateTime


Variables  ./TestData/Testdata.py


***Variables***
# Global Variables default empty if value not set
${BEARER_TOKEN}
${headers}
${body}
${files}
${auth}
${cookies}
${proxy}
${OauthScope}
${conversation_id}=  1ea9c6f3-3b7b-4085-a237-6ac8cb9a9bce
${CLIENTID}
${CLIENTSECRET}
${grant_type}
# default test data file Path
${PATH}=    ${CURDIR}\\TestData

*** Keywords ***
# set auth variable for basic auth with username and password
set Auth ${USERNAME} ${PASSWORD}
    Set test Variable   ${USERNAME}   ${USERNAME}
    Set test Variable   ${PASSWORD}  ${PASSWORD}
    ${auth}=  Create list  ${USERNAME}  ${PASSWORD}
    # Makes a variable available everywhere within the scope of the current test.
    Set test Variable   ${auth}   ${auth}


session creation ${API_BASE_ENDPOINT}
    Create Session  mysession  ${API_BASE_ENDPOINT}   verify=False  auth=${auth}  debug=0  cookies=${cookies}

# set proxy
#     &{proxy} =  create dictionary   http=http://proxy2:8080  https=http://proxy2:8080
#     Set Test Variable    ${proxy}    &{proxy}

set Scope ${OauthScope} and grant type ${grant_type}
    # Makes a variable available everywhere within the scope of the current test.
    Set test Variable   ${OauthScope}   ${OauthScope}
    Set test Variable   ${grant_type}   ${grant_type}
    
    # create dictionary based on oauth credentials and properties
    ${body}=    Create Dictionary  client_id=${CLIENTID}    client_secret=${CLIENTSECRET}    scope=${OauthScope}  Token_Name=cognito-awsUat  grant_type=${grant_type}
    Set test Variable   ${body}   ${body}


# get token object from response
grab token
    # verify request is successfull ,grab token and make it available to entire suite
    Should Be Equal As Strings  ${response.status_code}  200
    ${TOKEN}=  Get From Dictionary  ${response.json()}  access_token
    ${FULL_TOKEN}=  set variable  Bearer ${TOKEN}
    log to console  Token is ${FULL_TOKEN}
    # Token stored in BEARER_TOKEN variable
    Set Suite Variable   ${BEARER_TOKEN}   ${FULL_TOKEN}

send get request
    # send GET request and make response object available to other tests
    ${response}=     GET On Session  mysession              ${API_QUERY}  params=query=${API_PARAM}
    Set Test Variable    ${response}

# verification to confirm the response code
confirm response code ${res_code}
    Should Be Equal As Strings   ${res_code}  ${response.status_code}

# Verify object present in json response
# TO DO CONFIRM IF KEY:VALUE PRESENT IN RESPONSE
# object present in body ${verify_object}
#     &{json_object}=    evaluate    json.loads('''${verify_object}''')    json
#     ${body}=  Convert To String  ${response.content}
#     &{json_body}=    evaluate    json.loads('''${body}''')    json
#     # ${type_string}=    Evaluate     type($json_body).__name__
#     Log To Console     ${json_body}
#     FOR    ${key}    IN    @{json_object.keys()}
#         log to console     The current key is: ${key}
#         log to console      The value is: ${json_object['${key}']}
#         # Dictionary Should Contain Value  ${json_body}  ${json_object['${key}']}
#         # Dictionary Should Contain Key  ${json_body}  ${key}
#         Dictionary Should Contain Sub Dictionary  ${json_body}  ${json_object}
#         END
    


# verification confirm key present in response
confirm is present in response ${KeyInResponse}
    ${body}=  Convert To String  ${response.content}
    Should Contain  ${body}  ${KeyInResponse}
    Set test Variable   ${key}   ${KeyInResponse}
 

add headers ${headersArgs}
    ${header_string}  evaluate  json.loads('''${headersArgs}''')   json
    # Makes a variable available everywhere within the scope of the current test.
    Set test Variable   ${headers}   ${header_string}

add cookies ${cookiesArg}
    ${cookies_object}  evaluate  json.loads('''${cookiesArg}''')   json
    # Makes a variable available everywhere within the scope of the current suite.
    Set suite Variable   ${cookies}   ${cookies_object}

# Add auth token object to headers object
add Token
    ${json_obj}=  Set Variable    ${headers}
    ${headers}=  Extend Json Obj  ${json_obj}        Authorization    ${BEARER_TOKEN}

add json body ${body}
    ${json_string}  evaluate  json.dumps(${body})   json
    # Makes a variable available everywhere within the scope of the current test.
    Set test Variable   ${body}   ${json_string}

add formdata body ${body}
    ${form_data}=    Evaluate    {'mldata=': str(${body}).replace("'",'"')}
    # Makes a variable available everywhere within the scope of the current test.
    Set test Variable   ${files}   ${form_data}

add form-urlencoded body ${body}
    # convert to json
    ${json_string}=    evaluate    json.dumps(${body})    json
    ${json_string}  evaluate  json.loads('''${json_string}''')   json
    # Makes a variable available everywhere within the scope of the current test.
    Set test Variable   ${body}   ${json_string}


POST a Request with query ${QUERY}
    # set proxy
    ${response}=  Post On Session    mysession  ${QUERY}  data=${body}  headers=${headers}  files=${files}  
    # Makes a variable available everywhere within the scope of the current test.
    Set Test Variable    ${response}

# send post request without proxy mapping
nonProxy POST a Request with query ${QUERY}
    ${response}=  Post On Session    mysession  ${QUERY}  data=${body}  headers=${headers}  files=${files}  #proxies=${proxy}
    # Makes a variable available everywhere within the scope of the current test.
    Set Test Variable    ${response}

PUT a Request with query ${QUERY}
    # set proxy
    ${response}=  PUT On Session    mysession  ${QUERY}  data=${body}  headers=${headers}  proxies=${proxy}
    Set Test Variable    ${response}

GET Request with query ${QUERY}
    # set proxy
    ${response}=  Get On Session    mysession  ${QUERY}  headers=${headers}   proxies=${proxy}  #verify=False
    Set Test Variable    ${response}

set image ${image}
    # set image from testdata  dictionary
    ${file}=    GET FILE FOR STREAMING UPLOAD    ${PATH}\\${image}
    ${image_path}=    CREATE DICTIONARY    file    ${file}
    # Makes a variable available everywhere within the scope of the current test.
    Set Test Variable   ${body}   ${image_path}

set data file ${json_file}
    # get external data file from test data location
    ${file}=  Get File  ${PATH}\\${json_file}
    # Makes a variable available everywhere within the scope of the current test.
    Set Test Variable   ${body}   ${file}

    ${timestamp}=    Get Time    result_format=%Y-%m-%dT%H:%M:%S.%f
    Log  ${timestamp}