
# Insert your companies installation ID here.
$IGRP = 'XXXX'
# Create a date object
$date= (get-date).Date.ToString("yyyy-MM-dd")
# Prompt user to input their infinity login details. This user will need to have api permissions in order to execute the api calls below.
$cred = Get-Credential -Message "Please provide Infinity Cloud Credentials"

# Execute api call to generate a list of all the dial in groups for this installation and save to a CSV
Invoke-WebRequest "https://api.infinitycloud.com/config/v2/igrps/$IGRP/dgrps?display[]=dgrp&display[]=dgrpName&format=csv" -Method GET -UseBasicParsing -OutFile dgrp-list.csv -Credential $cred
# Import above created CSV
$list = import-csv dgrp-list.csv
# Loop through the list of dial-in-groups and perform below api call to export a full list of this groups fixed numbers.
Foreach ($obj in $list) {
    $numbers = invoke-RESTMethod "https://api.infinitycloud.com/config/v2/igrps/$IGRP/dgrps/$($obj.dgrp)/numbers/fixed?display[]=dgrpName&display[]=phoneNumber&display[]=channelName&display[]=usageFilter&format=jsonarray" -Method GET -Credential $cred -UseBasicParsing
    foreach ($a in $numbers) {
        # Export these fields to a csv called fixed_number_report_<date>.csv
        "$($a.dgrpName), $($a.phoneNumber), $($a.channelName), $($a.usageFilter)" | Out-File fixed_number_report_$date.csv -Append
    }
}
# Delete the dial in group csv that was created
Remove-Item dgrp-list.csv -recurse