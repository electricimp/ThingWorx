# ThingWorx Examples #

This document describes the example application provided with the [ThingWorx library](../README.md).

## DataSender Example ##

This example creates a ThingWorx Thing named `test_thing` (if it does not exist already) with two predefined Properties: 

- *data* &mdash; An integer value, converted to string, which starts at 1 and increases by 1 with every update. It restarts from 1 every time the example is restarted.
- *measure_time* &mdash; An integer value, which is the time in seconds since the epoch.

The application updates the Properties values every 10 seconds.
  
## Setup and Run ##

### ThingWorx Evaluation Server Configuration ###

- Login to the [ThingWorx Developer Portal](https://developer.thingworx.com/login) in your web browser.
- Click the **Evaluation Server** icon in the top right corner. **Note** The initial provisioning of Evaluation Server for a new account usually takes between 3-5 minutes.
- Copy the **Hostname** value from the pop-up and paste it into a plain text document or equivalent. This will be used as the value of the *THING_WORX_ENDPOINT* constant in the imp agent code:
![LaunchThingWorx](../png/LaunchThingWorx.png?raw=true)
- Click **Launch**. You will be redirected to the ThingWorx Composer page (usually a new browser tab)
- In the **ThingWorx Composer** page’s **Home** tab, click **+** under **Application Keys** in the **SECURITY** section:
![AddAppKey](../png/AddAppKey.png?raw=true)
- Enter any Application Key **Name**, eg. `testAppKey`.
- Click **Search** in the **User Name Reference** field under **General Information**, and choose the **Administrator** user:
![AppKeyUser](../png/AppKeyUser.png?raw=true)
- Choose a date and time for **Expiration Date** field.
- Click **Done** then click **Save**:
![AppKeyExpirationDate](../png/AppKeyExpirationDate.png?raw=true)
- On the **General Information** page select and copy the **keyId** field and paste into a plain text document or equivalent. This will be used as the value of the *THING_WORX_APPLICATION_KEY* constant in the imp agent code:
![AppKeyId](../png/AppKeyId.png?raw=true)

### Setting Up and Running the Application ###

- In [Electric Imp’s impCentral™](https://impcentral.electricimp.com) create a Product and Development Device Group.
- Assign a development device to the newly created Device Group.
- Open the code editor for the newly created Device Group.
- Copy the [DataSender source code](./DataSender.agent.nut) and paste it into the code editor as the agent code.
- Set the *THING_WORX_ENDPOINT* constant in the agent example code to the value of Evaluation Server Hostname you retrieved and saved above. Ensure it is prefixed with `https://`. The value should look like `"https://PP-1802281448E8.Devportal.Ptc.Io"`.
- Set the *THING_WORX_APPLICATION_KEY* constant in the agent example code to the value of the Application Key ID you retrieved and saved above:
![SetThingWorxConsts](../png/SetThingWorxConsts.png?raw=true)
- Click **Build and Force Restart**.
- Use the code editor’s log pane to confirm that data is being sent successfully:
![DataSenderLogs](../png/DataSenderLogs.png?raw=true)

### Notes ### 

- The hosted ThingWorx Evaluation Server is stopped after three hours of inactivity and, typically, it takes about one minute to start it again.
- You need to ensure the Server is started before running the example. To start the Server:
    - Click the **Evaluation Server** icon in the top right corner of the ThingWorx Developer Portal.
    - Check the Server status in the pop-up. If it is **Stopped**, click **Start**.

### Monitor the Properties Values in ThingWorx ###

- In the **ThingWorx Composer** page’s **Home** tab, click **Things** in the **MODELING** section.
- Click *test_thing* in the **Things** table:
![ThingsTable](../png/Things.png?raw=true)
- In the **test_thing** tab, click **Properties** in the **ENTITY INFORMATION** section.
- Ensure the Properties table contains **data** and **measure_time** Properties, and that their values are updated periodically if **Values** column’s refresh button is clicked:
![ThingProperties](../png/ThingProperties.png?raw=true)
