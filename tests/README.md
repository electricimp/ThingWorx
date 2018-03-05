# Test Instructions

The tests in the current directory are intended to check the behavior of the ThingWorx library. The current set of tests check:
- Thing manipulation methods of ThingWorx library: createThing, deleteThing, existThing
- Thing Property manipulation methods of ThingWorx library: createThingProperty, setPropertyValue
- processing of wrong parameters passed into the library methods

The tests are written for and should be used with [impt](https://github.com/electricimp/imp-central-impt). See [impt Testing Guide](https://github.com/electricimp/imp-central-impt/blob/master/TestingGuide.md) for the details of how to configure and run the tests.

The tests for ThingWorx library require pre-setup described below.

## ThingWorx Account Configuration

- Login to [ThingWorx Developer Portal](https://developer.thingworx.com) in your web browser.
- Click **Evaluation Server** icon in the top right corner of the Developer Portal.
- Copy and save somewhere Hostname value from the pop up. This will be used as the value of the *THING_WORX_ENDPOINT* environment variable.
- Click **Launch**. You will be redirected to the ThingWorx Composer page (usually a new tab).
![LaunchThingWorx](../png/LaunchThingWorx.png?raw=true)
- In the **ThingWorx Composer** **Home** tab click **Application Keys +** button in the **SECURITY** menu.
![AddAppKey](../png/AddAppKey.png?raw=true)
- Enter any Application Key **Name**, eg. `testAppKey`.
- Click **Search** button in **User Name Reference** field and choose **Administrator** user.
![AppKeyUser](../png/AppKeyUser.png?raw=true)
- Choose date and time for **Expiration Date** field.
- Click **Done**.
- Click **Save**.
![AppKeyExpirationDate](../png/AppKeyExpirationDate.png?raw=true)
- In the **General Information** page of your Application Key select and copy and save somewhere **keyId** field. This will be used as the value of the *THING_WORX_APPLICATION_KEY* environment variable.
![AppKeyId](../png/AppKeyId.png?raw=true)

## Environment Variables

- Set *THING_WORX_ENDPOINT* environment variable to the value of Evaluation Server Hostname you retrieved and saved in the previous steps, prefixed by `https://`. The value should look like `"https://PP-1802281448E8.Devportal.Ptc.Io"`.
- Set *THING_WORX_APPLICATION_KEY* environment variable to the value of Application Key Id you retrieved and saved in the previous steps.
- For integration with Travis set *EI_LOGIN_KEY* environment variable to the valid login key ID.

**IMPORTANT:** the hosted ThingWorx Evaluation Server is stopped after 3 hours of inactivity and typically take about one minute to start again.
You need to ensure the Server is started before running the tests.
To start the Server:
- Click **Evaluation Server** icon in the top right corner of the ThingWorx Developer Portal.
- Check the Server status in the pop up. If it is **Stopped**, click **Start** button.
