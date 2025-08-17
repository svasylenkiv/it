# Serverless API в AWS за 0$ і 30 секунд

## Тобі знадобляться

1. AWS Account, та налаштований AWS CLI з адмін доступом до акаунту
2. (бажано) Linux або Mac, для простоти експерименту, або Windows з WSL
3. python3 + pip встановлений на твоєму комп’ютері
4. базові навички користування командним рядком
5. розуміння що ти робиш і навіщо 🙂

## Приступимо!

1. Створи пусту папку в зберігатимеш цей міні проєкт, та перейди в неї
    
    ```bash
    mkdir -p my-simple-app && cd $_
    ```
    
2. Перевір чи маєш встановлену `aws cli` та чи можеш ти комунікувати з AWS через термінал. Якщо це спрацює, тоді будь готовий йти далі.
    
    ```bash
    aws sts get-caller-identity
    
    # Відповідь
    {
        "UserId": "XXXXXX",
        "Account": "XXXXXX",
        "Arn": "arn:aws:iam::XXXXX:user/petro_bamper"
    }
    ```
    
    <aside>
    💡
    
    Якщо не працює - подивись цей гайд
    https://docs.aws.amazon.com/cli/latest/userguide/getting-started-quickstart.html
    
    </aside>
    
3. Встанови `sam cli` використовуючи цей гайд: https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html
4. Перевір що `sam` встановлено, прописавши в терміналі:
    
    ```bash
    sam --version
    
    # має бути така відповідь або щось схоже
    SAM CLI, version 1.76.0
    ```
    
5. Якщо все добре, продовжуємо. Якщо ні - повертайся на пункт 2.
6. Ініціалізуй проєкт та вибери шаблон #1
    
    ```bash
    sam init
    ```
    
    ![image.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/f0b66a4d-273d-4242-b927-6c11084a54a8/e4dfc3a6-0990-4a05-b9e8-7f8e6be6d208/image.png)
    
7. Далі, вибери Hello World Example (1)
    
    ![image.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/f0b66a4d-273d-4242-b927-6c11084a54a8/97185c94-67a6-4665-b919-76f9b636de27/image.png)
    
8. Коли попросить про тип пакету і мову програмування, введи `y` 
    
    ```bash
    Use the most popular runtime and package type? (Python and zip) [y/N]:
    ```
    
9. X-Ray та CloudWatch insights нам не потрібні, тому вкажи `n` в наступних двох кроках
    
    ```bash
    Would you like to enable X-Ray tracing on the function(s) in your application?  [y/N]: n
    
    Would you like to enable monitoring using CloudWatch Application Insights?
    For more info, please view https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/cloudwatch-application-insights.html [y/N]: n
    ```
    
10. Присвой ім’я своєму проєкту
    
    ```bash
    Project name [sam-app]: my-app
    ```
    
11. В тебе має створитися папка з такою ж назвою і якимись файликами всередині
    
    ```bash
    my-app
    ├── README.md
    ├── __init__.py
    ├── events
    │   └── event.json
    ├── hello_world
    │   ├── __init__.py
    │   ├── app.py
    │   └── requirements.txt
    ├── samconfig.toml
    ├── template.yaml
    └── tests
        ├── __init__.py
        ├── integration
        │   ├── __init__.py
        │   └── test_api_gateway.py
        ├── requirements.txt
        └── unit
            ├── __init__.py
            └── test_handler.py
    ```
    
    ![image.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/f0b66a4d-273d-4242-b927-6c11084a54a8/3592c668-9741-4c5e-8f5c-924bac251bb2/image.png)
    
12. Більш за все нас цікавить папка `hello_world` і в ній файл `app.py`. Відкрий його у своєму текстовому редакторі.
13. Ти побачиш простенький пайтон код, який все що робить так це
    
    ```bash
        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": "hello world",
                # "location": ip.text.replace("\n", "")
            }),
        }
    
    ```
    
14. Можеш замінити “hello world” на будь-який текст який тобі подобається. Це і буде тим що робить твоє апі - повертає користувачу відповідь у вигляді такого повідомлення. 
15. Якщо тобі цікаво, можеш походити поміж файлами і подивитися що в них, але нічого в них не міняй, бо тоді не гарантія що воно запуститься 🙂
16. Тепер, коли все готово, запустимо білд.
    1. перейди в папку з проєктом (my-app) в моєму прикладі
        
        ```bash
        cd my-app
        ```
        
    2. Запусти білд
        
        ```bash
        sam build
        
        # Відповідь
        Starting Build use cache
        Manifest file is changed (new hash: 3298f13049d19cffaa37ca931dd4d421) or dependency folder (.aws-sam/deps/956851b6-af0b-4bf7-be9e-7295420a06b1) is missing for (HelloWorldFunction), downloading dependencies and copying/building source
        Building codeuri: /Users/oleh/Repos/aws-labs/serverless/my-app/hello_world runtime: python3.9 metadata: {} architecture: x86_64 functions: HelloWorldFunction
        Running PythonPipBuilder:CleanUp
        Running PythonPipBuilder:ResolveDependencies
        Running PythonPipBuilder:CopySource
        Running PythonPipBuilder:CopySource
        
        Build Succeeded
        
        Built Artifacts  : .aws-sam/build
        Built Template   : .aws-sam/build/template.yaml
        
        Commands you can use next
        =========================
        [*] Validate SAM template: sam validate
        [*] Invoke Function: sam local invoke
        [*] Test Function in the Cloud: sam sync --stack-name {{stack-name}} --watch
        [*] Deploy: sam deploy --guided
        ```
        
17. А тепер давай викотимо наше апі в AWS Cloud! Відповідай на відповіді як я, там де пусто нічого не пиши а клікай Enter.
    
    ```bash
    sam deploy --guided
    
    # Відповідь
    
    Configuring SAM deploy
    ======================
    
            Looking for config file [samconfig.toml] :  Found
            Reading default arguments  :  Success
    
            Setting default arguments for 'sam deploy'
            =========================================
            Stack Name [my-app]: 
            AWS Region [us-east-1]: 
            #Shows you resources changes to be deployed and require a 'Y' to initiate deploy
            Confirm changes before deploy [Y/n]: y
            #SAM needs permission to be able to create roles to connect to the resources in your template
            Allow SAM CLI IAM role creation [Y/n]: y
            #Preserves the state of previously provisioned resources when an operation fails
            Disable rollback [y/N]: y
            HelloWorldFunction may not have authorization defined, Is this okay? [y/N]: y
            Save arguments to configuration file [Y/n]: y
            SAM configuration file [samconfig.toml]: 
            SAM configuration environment [default]: 
    ```
    
    1. Через кілька секунд воно викотить наше апі. Тисни Y коли попросить `Deploy this changeset?`
        
        ```bash
        Deploying with following values
                ===============================
                Stack name                   : my-app
                Region                       : us-east-1
                Confirm changeset            : True
                Disable rollback             : True
                Deployment s3 bucket         : aws-sam-cli-managed-default-samclisourcebucket-6bkwiqvztyp7
                Capabilities                 : ["CAPABILITY_IAM"]
                Parameter overrides          : {}
                Signing Profiles             : {}
                
        Initiating deployment
        =====================
        
                Uploading to my-app/7968e4e49501e28bab5035683b1e663e.template  1196 / 1196  (100.00%)
        
        Waiting for changeset to be created..
        
        CloudFormation stack changeset
        -------------------------------------------------------------------------------------------------
        Operation                LogicalResourceId        ResourceType             Replacement            
        -------------------------------------------------------------------------------------------------
        + Add                    HelloWorldFunctionHell   AWS::Lambda::Permissio   N/A                    
                                 oWorldPermissionProd     n                                               
        + Add                    HelloWorldFunctionRole   AWS::IAM::Role           N/A                    
        + Add                    HelloWorldFunction       AWS::Lambda::Function    N/A                    
        + Add                    ServerlessRestApiDeplo   AWS::ApiGateway::Deplo   N/A                    
                                 yment47fc2d5f9d          yment                                           
        + Add                    ServerlessRestApiProdS   AWS::ApiGateway::Stage   N/A                    
                                 tage                                                                     
        + Add                    ServerlessRestApi        AWS::ApiGateway::RestA   N/A                    
                                                          pi                                              
        -------------------------------------------------------------------------------------------------
        
        Changeset created successfully. arn:aws:cloudformation:us-east-1:372803067194:changeSet/samcli-deploy1733692297/53a3ac78-7720-4ef1-90cd-7e7d0fe4b1ab
        
        Previewing CloudFormation changeset before deployment
        ======================================================
        ```
        
18. Підтверди, і чекай кілька секунд (до хвилини). 
19. Коли все успішно, маємо отримати таку відповідь. В цьому тексті є посилання на наше апі, яке тепер можеш перевірити!
    
    ```bash
    -------------------------------------------------------------------------------------------------
    Key                 HelloWorldFunctionIamRole                                                   
    Description         Implicit IAM Role created for Hello World function                          
    Value               arn:aws:iam::372803067194:role/my-app-HelloWorldFunctionRole-WdXkuc9Eicta   
    
    Key                 HelloWorldApi                                                               
    Description         API Gateway endpoint URL for Prod stage for Hello World function            
    Value               https://heepk2f6r9.execute-api.us-east-1.amazonaws.com/Prod/hello/          
    
    Key                 HelloWorldFunction                                                          
    Description         Hello World Lambda Function ARN                                             
    Value               arn:aws:lambda:us-east-1:372803067194:function:my-app-HelloWorldFunction-   
    QmhV6GWlyEZI                                                                                    
    ```
    
20. В моєму випадку це `https://heepk2f6r9.execute-api.us-east-1.amazonaws.com/Prod/hello/`
21. Коли відкриєш це у браузері, маєш побачити щось таке, що означатиме що все спрацювало!
    
    ![image.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/f0b66a4d-273d-4242-b927-6c11084a54a8/ce239788-9948-4a36-a6da-e103f4d0370c/image.png)
    

## Результат

Простеньке API яке повертає JSON об’єкт з повідомленням, коли звертаєшся до нього через HTTP запит. 

<aside>
💡

Згідно політики AWS Free Tier, таке АПІ не коштує нічого, якщо не перетинає позначку в кілька мільйонів запитів на місяць.

</aside>

## А тепер приберемо за собою

Коли награвся і нарадувався від свого першого апі, не забудь його видалити. Прибирати за собою - це завжди гарний тон.

Запусти наступну команду і підтверди всі пункти

```bash
sam delete

# Відповідь
Are you sure you want to delete the stack my-app in the region us-east-1 ? [y/N]: y
```

І незабаром, твоє апі буде знищене 😵

```bash
sam delete
        Are you sure you want to delete the stack my-app in the region us-east-1 ? [y/N]: y
        Are you sure you want to delete the folder my-app in S3 which contains the artifacts? [y/N]: y
        - Deleting S3 object with key my-app/9ed6794ec4f917f0859771406c2d0df2
        - Deleting S3 object with key my-app/7968e4e49501e28bab5035683b1e663e.template
        - Deleting Cloudformation stack my-app

Deleted successfully
```

## Дякую за увагу!