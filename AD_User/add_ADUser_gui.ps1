Import-Module ActiveDirectory

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$countryList = Import-Csv -Delimiter "," -Path C:\Scripts\user_reg\Data\country.csv

#--------------------------- functions ------------------------
function Create-Form {
    param (
        [Parameter(Mandatory=$true)]
        [String]$Title,

        [Parameter(Mandatory =$true)]
        [string]$Name,
        
        [int]$Width,

        [int]$Height
    )
    
    $form = New-Object System.Windows.Forms.Form
    $form.Text = $Title
    $form.Name = "${Name}Form"
    $form.StartPosition = 'CenterScreen'
    $form.Size = New-Object System.Drawing.Size($Width, $Height)

    $form
}

function Create-Label {
    param (
        [Parameter(Mandatory =$true)]
        [string]$Name,

        [string]$Content
    )

    $label = New-Object System.Windows.Forms.Label
    $label.Name = "${Name}Label"
    $label.Text = $Content
    #$label.Location = New-Object System.Drawing.Point
    #$label.Size = New-Object System.Drawing.Size

    $label

}

function Create-TextBox {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [string]$Content
        )
    
    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Name = "${Name}TextBox"
    $textBox.Text = $Content
    #$textBox.Location = New-Object System.Drawing.Point
    #$textBox.Size = New-Object System.Drawing.Size

    $textBox
}

function Create-CheckBox {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [String]$Title
        )

    $checkBox = New-Object System.Windows.Forms.CheckBox
    $checkBox.Name = "${Name}CheckBox"
    $checkBox.Text = $Title
    #$checkBox.Position = New-Object System.Drawing.Point
    #$checkBox.Size = New-Object System.Drawing.Size

    $checkBox
}

function Create-DropdownList {
    param (
        [Parameter(Mandatory = $true)]
        [String]$Name,

        [Parameter(Mandatory = $true)]
        [System.Windows.Forms.Form]$Form,

        [System.Collections.ArrayList]$List
    )

    $dropdown = New-Object System.Windows.Forms.ComboBox
    $dropdown.Name = "${Name}Dropdownlist"
    $dropdown.autoSize = $true
    foreach ($item in $List) {
        $dropdown.Items.Add($item.Name)
    }
    $dropdown.SelectedIndex = 0
    
    $dropdown
    
}


#--------------------------------user properties------------------------------------
$userProperties = @{
    GivenName = "TextBox"
    Surname = "TextBox"
    Initials = "TextBox"
    Name = "TextBox"
    DisplayName = "TextBox"
    Description = "TextBox"
    Office = "TextBox"
    OfficePhone = "TextBox"
    EmailAddress = "TextBox"
    HomePage = "TextBox"
    StreetAddress = "TextBox"
    POBox = "TextBox"
    City = "TextBox"
    State = "TextBox"
    PostalCode = "TextBox"
    Country = "Dropdown"
    UserPrincipalName = "TextBox"
    ChangePasswordAtLogon = "CheckBox"
    CannotChangePassword = "CheckBox"
    PasswordNeverExpires = "CheckBox"
    Enabled = "CheckBox"
    AccountPassword = "TextBox"
}

<#
foreach ($property in $userProperties.GetEnumerator()) {
    Write-Host "$($property.Name): $($property.Value)"
}
#>




# Create the Form
try {
    $form = Create-Form -Title "Create New AD-User" -Name "GUI" -Width 1500 -Height 800
}
catch {
    [System.Windows.Forms.MessageBox]::Show("Could not create GUI.","Gui Faliure",0,[System.Windows.Forms.MessageBoxIcon]::Error)
    exit 1
}


#Create and add controls to the form
try {
    foreach ($property in $userProperties.GetEnumerator()) {
        $propertyName = $property.Name
        $propertyType = $property.Value
    
        switch ($propertyType) {
            'TextBox' {
                $label = Create-Label -Name "${propertyName}Label" -Content $propertyName
                $textBox = Create-TextBox -Name "${propertyName}TextBox" -Content ""
                $form.Controls.Add($label)
                $form.Controls.Add($textBox)
                Break
            }
            'CheckBox' {
                $checkBox = Create-CheckBox -Name "${propertyName}CheckBox" -Title $propertyName
                $form.Controls.Add($checkBox)
                Break
            }
            'Dropdown' {
                $label = Create-Label -Name "${propertyName}_Label" -Content $propertyName
                $dropdown = Create-DropdownList -Name "${propertyName}_Dropdown" -List $countryList
                $form.Controls.Add($label)
                $form.Controls.Add($dropdown)
                Break
            }
            Default {
                Write-Host $propertyName
                throw "Invalid control type: $propertyType"
            }
        }
    }
}
catch {
    [System.Windows.Forms.MessageBox]::Show("Invalid GUI type: $($_.Exception.Message)","Error: Invalid Type",[System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
}

# Show the form
$form.ShowDialog()


# Close the form when done
$form.Close()