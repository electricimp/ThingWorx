# ThingWorx Examples

This document describes the example application provided with the [ThingWorx library](../README.md).

## DataSender Example

This example creates ThingWorx Thing named `test_thing` (if it does not exist already) with two predefined Properties and periodically updates the Properties values:
- the values are updated every 10 seconds.
- the Properties are:
  - `data` - integer value, converted to string, which starts at 1 and increases by 1 with every update. It restarts from 1 every time when the example is restarted.
  - `measure_time` - integer value, the time in seconds since the epoch.

## Setup and Run

### ThingWorx Evaluation Server Configuration

- Login to [ThingWorx Developer Portal](https://developer.thingworx.com) in your web browser.
- Click **Evaluation Server** icon in the top right corner of the Developer Portal. **Note:** The initial provisioning of Evaluation Server for a new account usually takes between 3-5 minutes.
- Copy **Hostname** value from the pop up and paste into a plain text document or equivalent. This will be used as the value of the *THING_WORX_ENDPOINT* constant in the imp agent code.
- Click **Launch**. You will be redirected to the ThingWorx Composer page (usually a new tab).
![LaunchThingWorx](../png/LaunchThingWorx.png?raw=true)
- In the **ThingWorx Composer** **Home** tab click **Application Keys "+"** button in the **SECURITY** menu.
![AddAppKey](../png/AddAppKey.png?raw=true)
- Enter any Application Key **Name**, eg. `testAppKey`.
- Click **Search** button in **User Name Reference** field and choose **Administrator** user.
![AppKeyUser](../png/AppKeyUser.png?raw=true)
- Choose date and time for **Expiration Date** field.
- Click **Done**.
- Click **Save**.
![AppKeyExpirationDate](../png/AppKeyExpirationDate.png?raw=true)
- In the **General Information** page of your Application Key select and copy **keyId** field and paste into a plain text document or equivalent. This will be used as the value of the *THING_WORX_APPLICATION_KEY* constant in the imp agent code.
![AppKeyId](../png/AppKeyId.png?raw=true)

### DataSender Example Setup and Run

- In the [Electric Imp's IDE](https://ide.electricimp.com) create new Product and Development Device Group.
- Assign device to the newly created Device Group.
- Copy the [DataSender source code](./DataSender.agent.nut) and paste it into the IDE as the agent code.
- Set *THING_WORX_ENDPOINT* constant in the agent example code to the value of Evaluation Server Hostname you retrieved and saved in the previous steps, prefixed by `https://`. The value should look like `"https://PP-1802281448E8.Devportal.Ptc.Io"`.
- Set *THING_WORX_APPLICATION_KEY* constant in the agent example code to the value of Application Key Id you retrieved and saved in the previous steps.
![SetThingWorxConsts](../png/SetThingWorxConsts.png?raw=true)
- Click **Build and Force Restart**.
- Check from the logs in the IDE that data sendings are successful.
![DataSenderLogs](../png/DataSenderLogs.png?raw=true)

**Note:** the hosted ThingWorx Evaluation Server is stopped after 3 hours of inactivity and, typically, it takes about one minute to start it again.
You need to ensure the Server is started before running the Example.
To start the Server:
- Click **Evaluation Server** icon in the top right corner of the ThingWorx Developer Portal.
- Check the Server status in the pop up. If it is **Stopped**, click **Start** button.

### Monitor the Properties Values in ThingWorx

- In the **ThingWorx Composer** **Home** tab click **Things** in the **MODELING** menu.
- Click *test_thing* in the **Things** table.
![ThingsTable](../png/Things.png?raw=true)
- In the **test_thing** tab click **Properties** in the **ENTITY INFORMATION** menu.
- Ensure the Properties table contains **data** and **measure_time** Properties and their values are updated periodically if **Refresh Properties** button is clicked.
![ThingProperties](../png/ThingProperties.png?raw=true)
