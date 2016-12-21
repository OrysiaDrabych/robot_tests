*** Settings ***
Resource        keywords.robot
Resource        resource.robot
Resource        base_keywords.robot
Suite Setup     Test Suite Setup
Suite Teardown  Test Suite Teardown

*** Variables ***
@{used_roles}  tender_owner  viewer


*** Test Cases ***
Можливість знайти закупівлю по ідентифікатору
  [Tags]   ${USERS.users['${viewer}'].broker}: Пошук тендера
  ...      ${USERS.users['${tender_owner}'].broker}: Пошук тендера
  ...      viewer  tender_owner
  ...      ${USERS.users['${viewer}'].broker}  ${USERS.users['${tender_owner}'].broker}
  ...      find_tender
  Завантажити дані про тендер
  :FOR  ${username}  in  @{used_roles}
  \  Run As  ${${username}}  Пошук тендера по ідентифікатору  ${TENDER['TENDER_UAID']}
  ${CONTRACT_UAID}=  Get variable value  ${USERS.users['${tender_owner}'].tender_data.data.contracts[0].contractID}
  Set Suite Variable  ${CONTRACT_UAID}


Можливість знайти договір по ідентифікатору
  [Tags]   ${USERS.users['${viewer}'].broker}: Пошук договору
  ...      ${USERS.users['${tender_owner}'].broker}: Пошук договору
  ...      viewer  tender_owner
  ...      ${USERS.users['${viewer}'].broker}  ${USERS.users['${tender_owner}'].broker}
  ...      find_contract
  :FOR  ${username}  IN  @{used_roles}
  \  Run As  ${${username}}  Пошук договору по ідентифікатору  ${CONTRACT_UAID}


Можливість отримати доступ до договору
  [Tags]   ${USERS.users['${tender_owner}'].broker}: Отримання прав доступу до договору
  ...      tender_owner
  ...      ${USERS.users['${tender_owner}'].broker}
  ...      access_contract
  Run As  ${tender_owner}  Отримати доступ до договору  ${CONTRACT_UAID}


Відображення дати підписання договору
  [Tags]   ${USERS.users['${viewer}'].broker}: Перегляд основних даних договору
  ...      tender_owner
  ...      ${USERS.users['${viewer}'].broker}
  ...      view_contract
  Звірити відображення поля dateSigned договору із ${USERS.users['${tender_owner}'].contract_data.data.dateSigned} для користувача ${tender_owner}


Можливість внести зміну до умов договору
  [Tags]   ${USERS.users['${tender_owner}'].broker}: Внесення зміни
  ...      tender_owner
  ...      ${USERS.users['${tender_owner}'].broker}
  ...      submit_change
  [Teardown]  Оновити LAST_MODIFICATION_DATE
  ${change_data}=  Підготувати дані про зміну до договору  ${tender_owner}
  Run As  ${tender_owner}  Внести зміну в договір  ${CONTRACT_UAID}  ${change_data}


Відображення опису причини зміни договору
  [Tags]   ${USERS.users['${viewer}'].broker}: Відображення зміни договору
  ...      tender_owner
  ...      ${USERS.users['${viewer}'].broker}
  ...      view_change
  Звірити відображення поля rationale зміни до договору для користувача ${viewer}


Відображення типу причини зміни договору
  [Tags]   ${USERS.users['${viewer}'].broker}: Відображення зміни договору
  ...      tender_owner
  ...      ${USERS.users['${viewer}'].broker}
  ...      view_change
  Звірити відображення причин зміни договору


Відображення опису причини зміни договору англійською мовою
  [Tags]   ${USERS.users['${viewer}'].broker}: Відображення зміни договору
  ...      tender_owner
  ...      ${USERS.users['${viewer}'].broker}
  ...      view_change
  Звірити відображення поля rationale_en зміни до договору для користувача ${viewer}


Відображення опису причини зміни договору російською мовою
  [Tags]   ${USERS.users['${viewer}'].broker}: Відображення зміни договору
  ...      tender_owner
  ...      ${USERS.users['${viewer}'].broker}
  ...      view_change
  Звірити відображення поля rationale_ru зміни до договору для користувача ${viewer}


Відображення непідтвердженого статусу зміни договору
  [Tags]   ${USERS.users['${viewer}'].broker}: Відображення зміни договору
  ...      tender_owner
  ...      ${USERS.users['${viewer}'].broker}
  ...      view_change
  Звірити поле зміни до договору із значенням
  ...     ${viewer}
  ...     ${CONTRACT_UAID}
  ...     pending
  ...     status


Можливість додати документ до зміни договору
  [Tags]   ${USERS.users['${tender_owner}'].broker}: Редагування договору
  ...      tender_owner
  ...      ${USERS.users['${tender_owner}'].broker}
  ...      upload_change_document  level2
  [Teardown]  Оновити LAST_MODIFICATION_DATE
  Додати документацію до зміни договору


Відображення заголовку документа до зміни договору
  [Tags]   ${USERS.users['${viewer}'].broker}: Відображення документації
  ...      viewer
  ...      ${USERS.users['${viewer}'].broker}
  ...      view_change_document  level2
  Звірити відображення поля title документа ${USERS.users['${tender_owner}']['change_doc']['id']} до договору з ${USERS.users['${tender_owner}']['change_doc']['name']} для користувача ${viewer}


Відображення вмісту документа до зміни договору
  [Tags]   ${USERS.users['${viewer}'].broker}: Відображення документації
  ...      viewer
  ...      ${USERS.users['${viewer}'].broker}
  ...      view_change_document  level2
  Звірити відображення вмісту документа ${USERS.users['${tender_owner}']['change_doc']['id']} до договору з ${USERS.users['${tender_owner}']['change_doc']['content']} для користувача ${viewer}


Відображення прив'язки документа до зміни договору
  [Tags]   ${USERS.users['${viewer}'].broker}: Відображення документації
  ...      viewer
  ...      ${USERS.users['${viewer}'].broker}
  ...      view_change_document  level2
  Звірити відображення поля documentOf документа ${USERS.users['${tender_owner}']['change_doc']['id']} до договору з change для користувача ${viewer}


Можливість вказати опис договору
  [Tags]   ${USERS.users['${tender_owner}'].broker}: Редагування договору
  ...      tender_owner
  ...      ${USERS.users['${tender_owner}'].broker}
  ...      modify_contract_description
  [Teardown]  Оновити LAST_MODIFICATION_DATE
  Run As  ${tender_owner}  Вказати опис договору  ${CONTRACT_UAID}


Можливість редагувати опис договору
  [Tags]   ${USERS.users['${tender_owner}'].broker}: Редагування договору
  ...      tender_owner
  ...      ${USERS.users['${tender_owner}'].broker}
  ...      modify_contract_description
  [Teardown]  Оновити LAST_MODIFICATION_DATE
  ${description}=  create_fake_sentence
  Set to dictionary  ${USERS.users['${tender_owner}']}  new_description=${description}
  Run As  ${tender_owner}  Редагувати договір  ${CONTRACT_UAID}  description  ${description}


Можливість редагувати опис причини зміни договору
  [Tags]   ${USERS.users['${tender_owner}'].broker}: Редагування зміни
  ...      tender_owner
  ...      ${USERS.users['${tender_owner}'].broker}
  ...      modify_change
  [Teardown]  Оновити LAST_MODIFICATION_DATE
  ${new_rationale}=  create_fake_sentence
  Run As  ${tender_owner}  Редагувати зміну  ${CONTRACT_UAID}  rationale  ${new_rationale}


Можливість редагувати назву договору
  [Tags]   ${USERS.users['${tender_owner}'].broker}: Редагування договору
  ...      tender_owner
  ...      ${USERS.users['${tender_owner}'].broker}
  ...      modify_contract_title
  [Teardown]  Оновити LAST_MODIFICATION_DATE
  ${title}=  create_fake_title
  Set to dictionary  ${USERS.users['${tender_owner}']}  new_title=${title}
  Run As  ${tender_owner}  Редагувати договір  ${CONTRACT_UAID}  title  ${title}


Можливість редагувати вартість договору
  [Tags]   ${USERS.users['${tender_owner}'].broker}: Редагування договору
  ...      tender_owner
  ...      ${USERS.users['${tender_owner}'].broker}
  ...      modify_amount
  [Teardown]  Оновити LAST_MODIFICATION_DATE
  ${value.amount}=  create_fake_amount
  Set to dictionary  ${USERS.users['${tender_owner}']}  new_amount=${value.amount}
  Run As  ${tender_owner}  Редагувати договір  ${CONTRACT_UAID}  value.amount  ${value.amount}


Можливість редагувати дату завершення дії договору
  [Tags]   ${USERS.users['${tender_owner}'].broker}: Редагування договору
  ...      tender_owner
  ...      ${USERS.users['${tender_owner}'].broker}
  ...      modify_period
  [Teardown]  Оновити LAST_MODIFICATION_DATE
  ${endDate}=  create_fake_date
  # ${period.endDate}=  add_minutes_to_date  ${endDate}  -40
  Set to dictionary  ${USERS.users['${tender_owner}']}  new_endDate=${endDate}
  Run As  ${tender_owner}  Редагувати договір  ${CONTRACT_UAID}  period.endDate  ${endDate}


Можливість редагувати дату початку дії договору
  [Tags]   ${USERS.users['${tender_owner}'].broker}: Редагування договору
  ...      tender_owner
  ...      ${USERS.users['${tender_owner}'].broker}
  ...      modify_period
  [Teardown]  Оновити LAST_MODIFICATION_DATE
  ${startDate}=  create_fake_date
  ${period.startDate}=  add_minutes_to_date  ${startDate}  -40
  Set to dictionary  ${USERS.users['${tender_owner}']}  new_startDate=${period.startDate}
  Run As  ${tender_owner}  Редагувати договір  ${CONTRACT_UAID}  period.startDate  ${period.startDate}


Можливість застосувати зміну договору
  [Tags]   ${USERS.users['${tender_owner}'].broker}: Застосування зміни договору
  ...      tender_owner
  ...      ${USERS.users['${tender_owner}'].broker}
  ...      apply_change
  [Teardown]  Оновити LAST_MODIFICATION_DATE
  Run As  ${tender_owner}  Застосувати зміну  ${CONTRACT_UAID}
  Set to dictionary  ${USERS.users['${tender_owner}'].change_data.data}  status=active


Відображення відредагованого опису договору
  [Tags]   ${USERS.users['${viewer}'].broker}: Редагування договору
  ...      viewer
  ...      ${USERS.users['${viewer}'].broker}
  ...      modify_contract_description  level2
  Звірити поле договору із значенням
  ...     ${viewer}
  ...     ${CONTRACT_UAID}
  ...     ${USERS.users['${tender_owner}'].new_description}
  ...     description


Відображення відредагованого опису причини зміни договору
  [Tags]   ${USERS.users['${viewer}'].broker}: Редагування зміни договору
  ...      viewer
  ...      ${USERS.users['${viewer}'].broker}
  ...      modify_change  level2
  Remove From Dictionary  ${USERS.users['${viewer}'].contract_data.data.changes[0]}  rationale
  Звірити поле договору із значенням
  ...     ${viewer}
  ...     ${CONTRACT_UAID}
  ...     ${USERS.users['${tender_owner}'].new_rationale}
  ...     changes[0].rationale


Відображення відредагованої назви договору
  [Tags]   ${USERS.users['${viewer}'].broker}: Редагування договору
  ...      viewer
  ...      ${USERS.users['${viewer}'].broker}
  ...      modify_contract_title  level2
  Звірити поле договору із значенням
  ...     ${viewer}
  ...     ${CONTRACT_UAID}
  ...     ${USERS.users['${tender_owner}'].new_title}
  ...     title


Відображення відредагованої вартості договору
  [Tags]   ${USERS.users['${viewer}'].broker}: Редагування договору
  ...      viewer
  ...      ${USERS.users['${viewer}'].broker}
  ...      modify_amount  level2
  Звірити поле договору із значенням
  ...     ${viewer}
  ...     ${CONTRACT_UAID}
  ...     ${USERS.users['${tender_owner}'].new_amount}
  ...     value.amount


Відображення відредагованої дати початку дії договору
  [Tags]   ${USERS.users['${viewer}'].broker}: Редагування договору
  ...      viewer
  ...      ${USERS.users['${viewer}'].broker}
  ...      modify_period  level2
  Звірити поле договору із значенням
  ...     ${viewer}
  ...     ${CONTRACT_UAID}
  ...     ${USERS.users['${tender_owner}'].new_startDate}
  ...     period.startDate


Відображення відредагованої дати завершення дії договору
  [Tags]   ${USERS.users['${viewer}'].broker}: Редагування договору
  ...      viewer
  ...      ${USERS.users['${viewer}'].broker}
  ...      modify_period  level2
  Звірити поле договору із значенням
  ...     ${viewer}
  ...     ${CONTRACT_UAID}
  ...     ${USERS.users['${tender_owner}'].new_endDate}
  ...     period.endDate


Відображення підтвердженого статусу зміни договору
  [Tags]   ${USERS.users['${viewer}'].broker}: Відображення зміни договору
  ...      tender_owner
  ...      ${USERS.users['${viewer}'].broker}
  ...      apply_change
  Звірити поле зміни до договору із значенням
  ...     ${viewer}
  ...     ${CONTRACT_UAID}
  ...     active
  ...     status


Неможливість додати документ до зміни договору після застосування зміни
  [Tags]   ${USERS.users['${tender_owner}'].broker}: Редагування договору
  ...      tender_owner
  ...      ${USERS.users['${tender_owner}'].broker}
  ...      add_change_contract_doc
  [Teardown]  Оновити LAST_MODIFICATION_DATE
  Run keyword and expect error  *  Додати документацію до зміни договору


Неможливість редагувати опис причини зміни договору після застосування зміни
  [Tags]   ${USERS.users['${tender_owner}'].broker}: Редагування зміни договору
  ...      tender_owner
  ...      ${USERS.users['${tender_owner}'].broker}
  ...      modify_change
  [Teardown]  Оновити LAST_MODIFICATION_DATE
  ${new_rationale}=  create_fake_sentence
  Run keyword and expect error  *  Run As  ${tender_owner}  Редагувати зміну  ${CONTRACT_UAID}  rationale  ${new_rationale}


Можливість завантажити документацію до договору
  [Tags]   ${USERS.users['${tender_owner}'].broker}: Додання документації до договору
  ...      tender_owner
  ...      ${USERS.users['${tender_owner}'].broker}
  ...      add_contract_doc  level2
  [Teardown]  Оновити LAST_MODIFICATION_DATE
  Додати документацію до договору


Відображення заголовку документації до договору
  [Tags]   ${USERS.users['${viewer}'].broker}: Відображення документації
  ...      viewer
  ...      ${USERS.users['${viewer}'].broker}
  ...      view_contract_doc  level2
  Звірити відображення поля title документа ${USERS.users['${tender_owner}']['contract_doc']['id']} до договору з ${USERS.users['${tender_owner}']['contract_doc']['name']} для користувача ${viewer}


Відображення вмісту документації до договору
  [Tags]   ${USERS.users['${viewer}'].broker}: Відображення документації
  ...      viewer
  ...      ${USERS.users['${viewer}'].broker}
  ...      view_contract_doc  level2
  Звірити відображення вмісту документа ${USERS.users['${tender_owner}']['contract_doc']['id']} до договору з ${USERS.users['${tender_owner}']['contract_doc']['content']} для користувача ${viewer}


Відображення прив'язки документа до договору
  [Tags]   ${USERS.users['${viewer}'].broker}: Відображення документації
  ...      viewer
  ...      ${USERS.users['${viewer}'].broker}
  ...      view_contract_doc  level2
  Звірити відображення поля documentOf документа ${USERS.users['${tender_owner}']['contract_doc']['id']} до договору з contract для користувача ${viewer}


Можливість вказати причини розірвання договору
  [Tags]   ${USERS.users['${tender_owner}'].broker}: Редагування договору
  ...      tender_owner
  ...      ${USERS.users['${tender_owner}'].broker}
  ...      termination_reasons
  [Teardown]  Оновити LAST_MODIFICATION_DATE
  Run As  ${tender_owner}  Вказати причини розірвання договору  ${CONTRACT_UAID}


Можливість редагувати причини розірвання договору
  [Tags]   ${USERS.users['${tender_owner}'].broker}: Редагування договору
  ...      tender_owner
  ...      ${USERS.users['${tender_owner}'].broker}
  ...      termination_reasons
  [Teardown]  Оновити LAST_MODIFICATION_DATE
  ${terminationDetails}=  create_fake_sentence
  Set to dictionary  ${USERS.users['${tender_owner}']}  new_termination_details=${terminationDetails}
  Run As  ${tender_owner}  Редагувати договір  ${CONTRACT_UAID}  terminationDetails  ${terminationDetails}


Відображення відредагованих причин розірвання договору
  [Tags]   ${USERS.users['${viewer}'].broker}: Редагування договору
  ...      viewer
  ...      ${USERS.users['${viewer}'].broker}
  ...      termination_reasons  level2
  Звірити поле договору із значенням
  ...     ${viewer}
  ...     ${CONTRACT_UAID}
  ...     ${USERS.users['${tender_owner}'].new_termination_details}
  ...     terminationDetails


Можливість вказати дійсно оплачену суму
  [Tags]   ${USERS.users['${tender_owner}'].broker}: Редагування договору
  ...      tender_owner
  ...      ${USERS.users['${tender_owner}'].broker}
  ...      amount_paid
  [Teardown]  Оновити LAST_MODIFICATION_DATE
  Run As  ${tender_owner}  Вказати дійсно оплачену суму  ${CONTRACT_UAID}


Можливість редагувати обсяг дійсно оплаченої суми
  [Tags]   ${USERS.users['${tender_owner}'].broker}: Редагування договору
  ...      tender_owner
  ...      ${USERS.users['${tender_owner}'].broker}
  ...      amount_paid
  [Teardown]  Оновити LAST_MODIFICATION_DATE
  ${amountPaid.amount}=  create_fake_amount
  Set to dictionary  ${USERS.users['${tender_owner}']}  new_amountPaid_amount=${amountPaid.amount}
  Run As  ${tender_owner}  Редагувати договір  ${CONTRACT_UAID}  amountPaid.amount  ${amountPaid.amount}


Відображення відредагованого обсягу дійсно оплаченої суми
  [Tags]   ${USERS.users['${viewer}'].broker}: Редагування договору
  ...      viewer
  ...      ${USERS.users['${viewer}'].broker}
  ...      amount_paid  level2
  Звірити поле договору із значенням
  ...     ${viewer}
  ...     ${CONTRACT_UAID}
  ...     ${USERS.users['${tender_owner}'].new_amountPaid_amount}
  ...     amountPaid.amount


Відображення врахованого ПДВ в дійсно оплаченій сумі
  [Tags]   ${USERS.users['${viewer}'].broker}: Відображення основних даних договору
  ...      tender_owner
  ...      ${USERS.users['${viewer}'].broker}
  ...      amount_paid
  Звірити відображення поля amountPaid.valueAddedTaxIncluded договору із ${USERS.users['${tender_owner}']['terminating_data'].data.amountPaid.valueAddedTaxIncluded} для користувача ${tender_owner}


Відображення валюти дійсно оплаченої суми
  [Tags]   ${USERS.users['${viewer}'].broker}: Відображення основних даних договору
  ...      tender_owner
  ...      ${USERS.users['${viewer}'].broker}
  ...      amount_paid
  Звірити відображення поля amountPaid.currency договору із ${USERS.users['${tender_owner}']['terminating_data'].data.amountPaid.currency} для користувача ${tender_owner}


Можливість завершити договір
  [Tags]   ${USERS.users['${tender_owner}'].broker}: Завершення договору
  ...      tender_owner
  ...      ${USERS.users['${tender_owner}'].broker}
  ...      contract_termination
  [Teardown]  Оновити LAST_MODIFICATION_DATE
  Run As  ${tender_owner}  Закінчити договір  ${CONTRACT_UAID}


Неможливість редагувати догововір після його завершення
  [Tags]   ${USERS.users['${tender_owner}'].broker}: Редагування договору
  ...      tender_owner
  ...      ${USERS.users['${tender_owner}'].broker}
  ...      contract_termination
  [Teardown]  Оновити LAST_MODIFICATION_DATE
  Run keyword and expect error  *  Додати документацію до договору
