# Overview 
EnableBranchProtection a simple web service written in Powershell that listens for organization repository events. When a repository is created and initialized, this web service enable the protection on the main branch and notify the creator with an @mention in an issue within the repository that outlines the protections that were added.


## Deploy the web service to Azure Functions App
1. Clone this repo locally and open in Visual Studio Code
2. [Sign in to Azure using Visual Studio Code](https://docs.microsoft.com/en-us/azure/azure-functions/functions-create-first-function-vs-code?pivots=programming-language-powershell#sign-in-to-azure)
3. [Publish the project to Azure](https://docs.microsoft.com/en-us/azure/azure-functions/functions-create-first-function-vs-code?pivots=programming-language-powershell#publish-the-project-to-azure)
4. [Set required application settings ](https://docs.microsoft.com/en-us/azure/azure-functions/functions-how-to-use-azure-function-app-settings): 
>- Create an app setting with name githubToken and set value to [personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
5. [Create a GitHub webwook](https://developer.github.com/webhooks/creating/) in the organization you'd like to protect. When creating the webhook scope it to repository events only and set Content type to application/json. The payload url should be configured to point to the Azure Function trigger url along with Function API key that will look like: https://***{NameOfFunctionApp}***.azurewebsites.net/api/***{NameOfFunction}***?code=*******
6. Create a new repository to test
7. review the newly created repository, it should have branch protection enabled and notified via issue.

---
### Resources:
>- https://docs.github.com/en/rest/reference/branches#update-branch-protection
>- https://docs.github.com/en/rest/reference/issues#create-an-issue