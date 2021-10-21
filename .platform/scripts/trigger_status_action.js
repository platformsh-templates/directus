/**
 * This activity script gets
 *  the URL of the new environment from PSH,
 *  then requests the originating branch from the Github API (Github is largely unaware of PR branches it seems)
 *  then triggers a Github Action to build a linux container that runs cypress tests against the PR environment
 */

 const ghUser = 'platformsh-templates'; // found in the url e.g. github.com/ghUser/ghRepo
 const ghRepo = 'directus';
 
 try {
   // be sure it's a real deployment
   if (typeof activity.payload.deployment === "undefined") {
     console.log(
       "Deployment payload (and therefore Variables) is unavailable in this state: " +
         activity.state
     );
     throw new Error("No deployment payload");
   }
   // get any variables necessary
   var githubToken = variables()["GITHUB_AUTH"];
 
   // verify the run was successful and environment is active
   if (
     activity.result !== "success" ||
     activity.payload.environment.status !== "active" ||
     !githubToken
   ) {
     console.log("A fatal error has occurred");
     console.log("Activity Result", activity.result);
     console.log("Activity Env Status", activity.payload.environment.status);
     console.log(githubToken)
     console.log(getEnvironmentVariables()["GITHUB_AUTH"])
    //  console.log(variables())
     console.log("Github token length", githubToken.length);
     throw new Error("Fatal Error");
   }
 
   // get the URL of the environment (dynamic)
   var routes = activity.payload.deployment.routes;
   var route = Object.keys(activity.payload.deployment.routes).reduce(function (
     accumulator,
     key
   ) {
     return routes[key].primary ? key : accumulator;
   },
   routes[0] || false);
 
   if (!route) {
     throw new Error(`No route provided: ${routes}`);
   }
 
   // PULL REQUESTS
   // get the original branch from the pull request
   getOriginalBranchName(
     activity.payload.environment.name.split("-")[1],
     githubToken,
     function (err, ref) {
       if (err) {
         console.log("error getting branch", err);
         throw new Error(err);
       }
       // trigger the github action script
       console.log("ref", ref);
       trigger_github_action(route, ref, githubToken);
     }
   );
 } catch (exception) {
   console.log("An exception has been thrown: " + exception);
 }
 
 /**
  *
  * @param {string} pullRequest The number of the pull request (e.g. 233)
  * @param {string} githubToken Your personal Github Token
  * @param {function} cb A function with the arguments (err, ref) - use this to access results.
  */
 function getOriginalBranchName(pullRequest, githubToken, cb) {
   var requestOptions = {
     method: "GET",
     headers: {
       Accept: "application/vnd.github.v3+json",
       Authorization: `Bearer ${githubToken}`,
       "Content-Type": "application/json",
     },
     redirect: "follow",
   };
   var response = fetch(
     `https://api.github.com/repos/${ghUser}/${ghRepo}/pulls/${pullRequest}`,
     requestOptions
   );
   if (!response.ok) {
     console.log(
       "Request to Github Pull Request API Failed",
       response.body.text()
     );
     cb("Failed to contact Github API");
   } else {
     var responseJson = response.json();
     var responseJsonStr = JSON.stringify(responseJson);
     var responseJsonParsed = JSON.parse(JSON.stringify(responseJson));
     if (responseJson) {
       cb(null, responseJsonParsed.head.ref);
     } else {
       cb("could not find remote ref");
     }
   }
 }
 
 /**
  *
  * @param {string} baseUrl The base URL created by Platform.sh
  * @param {string} branchName The branch name that created the Pull Request
  * @param {string} githubToken Your personal Github Token
  */
 function trigger_github_action(baseUrl, branchName, githubToken) {
   var requestOptions = {
     method: "POST",
     headers: {
       Accept: "application/vnd.github.v3+json",
       Authorization: `Bearer ${githubToken}`,
       "Content-Type": "application/json",
     },
     body: JSON.stringify({
       ref: branchName,
       inputs: {
         baseUrl: baseUrl,
       },
     }),
     redirect: "follow",
   };
 
   var response = fetch(
     `https://api.github.com/repos/${ghUser}/${ghRepo}/actions/workflows/lighthouse.yaml/dispatches`,
     requestOptions
   );
 
   if (!response.ok) {
     console.log("Request to Github Actions API Failed", response.body.text());
   } else {
     console.log("Request to Github Actions API Succeeded");
     // this returns a 204 with no content
   }
 }
 
 /**
  * A simple function to parse the environment variables. This reads them exactly as they are created in the PSH UI.
  * e.g. if you need env:TOKEN you need to ask for variables()['env:TOKEN'] explicitly.
  */
 function variables() {
   var vars = {};
   activity.payload.deployment.webapps.directus.variables.forEach(function (variable) {
     vars[variable.name] = variable.value;
   });
 
   return vars;
 }

 function getEnvironmentVariables() {
    return activity.payload.deployment.variables.reduce(
      (vars, { name, value }) => ({
        ...vars,
        [name]: value,
      }),
      {}
    );
  }


