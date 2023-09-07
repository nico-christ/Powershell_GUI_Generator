Import-Module ActiveDirectory

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

#$userProperties = Import-Csv -Delimiter "," -Path C:\Scripts\user_reg\Data\userdata.csv
$countryList = Import-Csv -Delimiter "," -Path C:\Scripts\user_reg\Data\country.csv
$officeList = @("Koeln", "Hamburg", "Sonstiges")

<#------------------------------ functions------------------------------------
these are in the "gui_test.ps1"
#>
function Create-Form {
    param (
        [Parameter(Mandatory=$true)]
        [String]$Title,

        [Parameter(Mandatory=$true)]
        [string]$Name,

        [Parameter()]
        [int]$Width,

        [Parameter()]
        [int]$Height,

        [Parameter(Mandatory=$true)]
        [String]$StartPosition
    )

    if ($Name -eq $null) {
        throw "Form must have a Name"
    }
    elseif ($Title -eq $null) {
        throw "The Form needs a Title."
    }
    
    # Create the form
    $Form = New-Object System.Windows.Forms.Form
    $Form.Text = $Title
    $Form.Name = $Name
    $Form.StartPosition = $StartPosition

    #adds the width and height if given
    if ($Width) {
            # Validate Width parameter
        if ($Width -le 0) {throw "Width must be greater than 0."}
        $Form.Width = $Width
    }
    if ($Height) {
        if ($Height -le 0) {throw "Height must be greater than 0."}
        $Form.Height = $Height
    }

    return $Form
}

function Create-GroupBox {
    param (
        [Parameter()]
        [String]$Title,

        [Parameter()]
        [int]$Width,
        [Parameter()]
        [int]$Height,

        [Parameter()]
        [int]$PosX,
        [Parameter()]
        [int]$PosY
    )

    $groupBox = New-Object System.Windows.Forms.GroupBox
    $groupBox.Text = $Title
    $groupBox.Name = "${title}_groupBox"

    #adds the width and height if given
    if ($Width) {$groupBox.Width = $Width}
    if ($Height) {$groupBox.Height = $Height}

    #adds the X-Pos and Y-Pos if given
    if ($PosX) {$groupBox.Left = $PosX}
    if ($PosY) {$groupBox.Top = $PosY}

    return $groupBox
}

function Create-Label {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [string]$Content,

        [Parameter()]
        [int]$Width,
        [Parameter()]
        [int]$Height,

        [Parameter()]
        [int]$PosX,
        [Parameter()]
        [int]$PosY
    )

    $label = New-Object System.Windows.Forms.Label
    $label.Name = "${Name}Label"
    $label.Text = $Content
    #adds the width and height if given
    if ($Width) {$label.Width = $Width}
    if ($Height) {$label.Height = $Height}

    #adds the X-Pos and Y-Pos if given
    if ($PosX) {$label.Left = $PosX}
    if ($PosY) {$label.Top = $PosY}

    return $label
}

function Create-TextBox {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [string]$Content,

        [Parameter()]
        [int]$Width,
        [Parameter()]
        [int]$Height,

        [Parameter()]
        [int]$PosX,
        [Parameter()]
        [int]$PosY
    )

    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Name = "${Name}TextBox"
    $textBox.Text = $Content
    $textBox.Font = New-Object System.Drawing.Font("Consolas",10,[System.Drawing.FontStyle]::Regular)
    
    #adds the width and height if given
    if ($Width) {$textBox.Width = $Width}
    if ($Height) {$textBox.Height = $Height}

    #adds the X-Pos and Y-Pos if given
    if ($PosX) {$textBox.Left = $PosX}
    if ($PosY) {$textBox.Top = $PosY}

    return $textBox
}

function Create-CheckBox {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [String]$Title,

        [Parameter()]
        [int]$Width,
        [Parameter()]
        [int]$Height,

        [Parameter()]
        [int]$PosX,
        [Parameter()]
        [int]$PosY
    )

    $checkBox = New-Object System.Windows.Forms.CheckBox
    $checkBox.Name = "${Name}CheckBox"
    $checkBox.Text = $Title

    #adds the width and height if given
    if ($Width) {$checkBox.Width = $Width}
    if ($Height) {$checkBox.Height = $Height}

    #adds the X-Pos and Y-Pos if given
    if ($PosX) {$checkBox.Left = $PosX}
    if ($PosY) {$checkBox.Top = $PosY}

    return $checkBox
}

function Create-DropdownList {
    param (
        [Parameter(Mandatory = $true)]
        [String]$Name,

        [Parameter(Mandatory = $true)]
        [System.Windows.Forms.Form]$Form,

        [Parameter(Mandatory = $true)]
        [System.Collections.ArrayList]$List,

        [Parameter()]
        [int]$Width,
        [Parameter()]
        [int]$Height,

        [Parameter()]
        [int]$PosX,
        [Parameter()]
        [int]$PosY
    )
    
    $dropdown = New-Object System.Windows.Forms.ComboBox
    $dropdown.Name = "${Name}Dropdownlist"
    $dropdown.DataSource = $List #uses the data from the countryList
    $dropdown.DisplayMember = "Name"# Displays the country names
    $dropdown.Font = New-Object System.Drawing.Font("Lucida Console",10,[System.Drawing.FontStyle]::Regular)


    #adds the width and height if given
    if ($Width) {$dropdown.Width = $Width}
    if ($Height) {$dropdown.Height = $Height}

    #adds the X-Pos and Y-Pos if given
    if ($PosX) {$dropdown.Left = $PosX}
    if ($PosY) {$dropdown.Top = $PosY}

    return $dropdown
}

function Create-Button {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ButtonName,

        [Parameter(Mandatory=$true)]
        [string]$ButtonText,

        [Parameter(Mandatory=$true)]
        [System.Windows.Forms.DockStyle]$ButtonDockStyle,

        [Parameter()]
        [int]$Width,

        [Parameter()]
        [int]$Height,

        [Parameter()]
        [int]$PosX,

        [Parameter()]
        [int]$PosY,

        # Sets the Button Dialogtype
        [Parameter()]
        [Windows.Forms.DialogResult]$DialogResult,

        [Parameter(Mandatory=$true)]
        [ScriptBlock]$ButtonAction
    )
    
    $button = New-Object System.Windows.Forms.Button
    $button.Name = $ButtonName
    $button.Text = $ButtonText

    #adds the width and height if given
    if ($Width) {$button.Width = $Width}
    if ($Height) {$button.Height = $Height}

    #adds the X-Pos and Y-Pos if given
    if ($PosX) {$button.Left = $PosX}
    if ($PosY) {$button.Top = $PosY}
    
    # Set the dock style of the button
    $button.Dock = $ButtonDockStyle

    $button.DialogResult = $DialogResult
    
    # Add the button click event handler
    $button.Add_Click($ButtonAction)
    
    return $button
}

function Get-StringFromTextBox {
    param (
        [Parameter(Mandatory=$true)]
        [System.Windows.Forms.TextBox]$TextBox
    )

    $string = $TextBoxName.Text.Trim()
    return $string
}

function Get-BoolFromCheckBox {
    param (
        [Parameter(Mandatory=$true)]
        [System.Windows.Forms.CheckBox]$CheckBox
    )

    $bool = $CheckBoxName.Checked
    return $bool
}

function Get-StringFromComboBox {
    param (
        [Parameter(Mandatory=$true)]
        [System.Windows.Forms.ComboBox]$ComboBox
    )

    $string = $ComboBoxName.Text
    return $string
}
<#
function Get-UserData {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ObjectName,
        [Parameter(Mandatory=$true)]
        [String]$ObjectType
    )

    switch ($ObjectType) {
        'TextBox' {
            Get-StringFromTextBox -TextBox 
        }
        'ComboBox' {
            return $ObjectName.Text
        }
        'CheckBox' {
            return $ObjectName.Checked
        }
        Default {throw "Invalid Object Type. $ObjectType"}
    }
}
#>
function Get-Country() { #//TODO Get-country fix
    try {
        $matchingCountry = $countryList | Where-Object { $_.Country -eq $listBox.SelectedItem } # matching pair wird gesucht

        if ($matchingCountry) {

            return @{c = $matchingCountry.Alpha_2_code; co = $matchingCountry.Country}

        } else {

            throw "No matching country found."

        }

    } catch {

        [System.Windows.Forms.MessageBox]::Show("Too many false attempts. Closing Script.","Error: Closing Script",[System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)

    }
}

function Write-User {
    $userProperties = {
        #Allgemein
            GivenName = (Get-StringFromTextBox -TextBox $GivenNameTextBox)
            Surname = (Get-StringFromTextBox -TextBox $SurnameTextBox)
            Initials = (Get-StringFromTextBox -TextBox $InitialsTextBox)
            Name = (Get-StringFromTextBox -TextBox $NameTextBox)
            DisplayName = (Get-StringFromTextBox -TextBox $DisplayNameTextBox)
            Description = (Get-StringFromTextBox -TextBox $DescriptionTextBox)
            Office = (Get-StringFromComboBox -ComboBox $OfficeComboBox)
            OfficePhone = (Get-StringFromTextBox -TextBox $OfficePhoneTextBox)
            EmailAddress = (Get-StringFromTextBox -TextBox $EmailAdressTextBox)
            HomePage = (Get-StringFromTextBox -TextBox $HomepageTextBox)
    
        #Adresse
            #StreetAddress = Get-UserData -TextBox $StreetAdressTextBox
            #POBox = Get-UserData -TextBox $POBoxTextBox
            #City = Get-UserData -TextBox $CityTextBox
            #State = Get-UserData -TextBox $StateTextBox
            #PostalCode = Get-UserData -TextBox $PostalcodeTextBox
            #Country = $null
    
        #Konto
            #UserPrincipalName = $null
            #-notworking LockedOut = InputBool "Account Suspention?"
    
        #AccountOptions
            #ChangePasswordAtLogon = Get-UserData -CheckBox $ChangePasswordAtLogonCheckBox
            #CannotChangePassword = Get-UserData -CheckBox $CannotChangePasswordCheckBox
            #PasswordNeverExpires = Get-UserData -CheckBox $PasswordNeverExpiresCheckBox
            #Enabled = Get-UserData -CheckBox $EnabledCheckBox
            #SamAccountName = 
    
        #password
            #AccountPassword = ConvertTo-SecureString (Generate-Password -PasswordLength (IsInt "Enter Passwordlength")) -AsPlainText -Force
            #Certificates = 
    
        #Miscellaneous
            #Path = $null
            #ProfilePath =
            #Server =
    }
    return $userProperties
}


#----------------------- create form ---------------------------------------------
$form = Create-Form -Title "New AD User" -Name "ADUserGUI" -StartPosition "Centerscreen" -Width 1000 -Height 730

#------------------------- edit form -------------------------------------------------
#$form.BackgroundImage = "C:\Share\Wallpaper\wp2132611-pepe-the-frog-wallpapers.jpg"
#$form.FormBorderStyle = "Fixed3D"


#---------------------- create Groupboxes ----------------------------------------
$groupBoxGeneral = Create-GroupBox -Title "General" -Width 270 -Height 375 -PosX 20 -PosY 20 # GroupBox um den Allgemein Tab ein zugeben
$groupBoxAddress = Create-GroupBox -Title "Address" -Width 270 -Height 210 -PosX 20 -PosY 420 # GroupBox um den Adress Tab ein zu geben
#$groupBoxAccount = Create-GroupBox -Title "Account" -Width 400 -Height //TODO -PosX //TODO -PosY //TODO# GroupBox um den Konto Tab ein zu geben
#$groupBoxAccountOptions = Create-GroupBox -Title "Account Options" #-Width 380 -Height //TODO -PosX //TODO -PosY //TODO# GroupBox um die Konto Optionen ein zu geben
#$groupBoxPassword = Create-GroupBox -Title "Password" #-Width 400 -Height //TODO -PosX //TODO -PosY //TODO# GroupBox um den Passwort Tab ein zu geben
#$groupBoxMiscellaneous = Create-GroupBox -Title "Miscellaneous" # GroupBox um Verschiedenes ein zu geben
#$groupBoxControls = Create-GroupBox -Title "" -Width 830 -Height 30 -PosX 10 -PosY 970

#------------------------------ create tab general -----------------------------------
$form.Controls.Add($groupBoxGeneral)

$GivenNameLabel = Create-Label -Name "GivenNameLabel" -Content "First Name" -Width 80 -Height 30 -PosX 20 -PosY 20
$GivenNameTextBox = Create-TextBox -Name "GivenNameTextBox" -Content "Fritz" -Width 120 -Height 30 -PosX 100 -PosY 20

$SurnameLabel = Create-Label -Name "SurnameLabel" -Content "Surname" -Width 80 -Height 30 -PosX 20 -PosY 50
$SurnameTextBox = Create-TextBox -Name "SurnameTextBox" -Content "Meier" -Width 120 -Height 30 -PosX 100 -PosY 50

$InitialsLabel = Create-Label -Name "InitialsLabel" -Content "Initials" -Width 80 -Height 30 -PosX 20 -PosY 80
$InitialsTextBox = Create-TextBox -Name "InitialsTextBox" -Content "FM" -Width 25 -Height 30 -PosX 100 -PosY 80

$NameLabel = Create-Label -Name "NameLabel" -Content "Username" -Width 80 -Height 30 -PosX 20 -PosY 110
$NameTextBox = Create-TextBox -Name "NameTextBox" -Content "fritzmeier" -Width 120 -Height 30 -PosX 100 -PosY 110

$DisplayNameLabel = Create-Label -Name "DisplayNameLabel" -Content "Displayname" -Width 80 -Height 30 -PosX 20 -PosY 140
$DisplayNameTextBox = Create-TextBox -Name "DisplayNameTextBox" -Content "Fritz Meier" -Width 120 -Height 30 -PosX 100 -PosY 140

$DescriptionLabel = Create-Label -Name "DescriptionLabel" -Content "Description" -Width 80 -Height 30 -PosX 20 -PosY 170
$DescriptionTextBox = Create-TextBox -Name "DescriptionTextBox" -Content "This is a description." -PosX 100 -PosY 170
$DescriptionTextBox.Size = New-Object System.Drawing.Size(150, 70)
$DescriptionTextBox.Multiline = $true

$OfficeLabel = Create-Label -Name "OfficeLabel" -Content "Office" -Width 80 -Height 30 -PosX 20 -PosY 250
$OfficeComboBox = Create-DropdownList -Name "OfficeComboBox" -List $officeList -Form $form -Width 120 -Height 30 -PosX 100 -PosY 250

$OfficePhoneLabel = Create-Label -Name "OfficePhoneLabel" -Content "Office Phone" -Width 80 -Height 30 -PosX 20 -PosY 280
$OfficePhoneTextBox = Create-TextBox -Name "OfficePhoneTextBox" -Content "0123456789" -Width 120 -Height 30 -PosX 100 -PosY 280

$EmailAdressLabel = Create-Label -Name "EmailAdressLabel" -Content "Email" -Width 80 -Height 30 -PosX 20 -PosY 310
$EmailAdressTextBox = Create-TextBox -Name "EmailAdressTextBox" -Content "fritz.meier@soprasteria.com" -Width 150 -Height 30 -PosX 100 -PosY 310
$EmailAdressTextBox.Font = New-Object System.Drawing.Font("Consolas",8,[System.Drawing.FontStyle]::Regular)

$HomepageLabel = Create-Label -Name "HomepageLabel" -Content "Website" -Width 80 -Height 30 -PosX 20 -PosY 340
$HomepageTextBox = Create-TextBox -Name "HomepageTextBox" -Content "www.fritz-meier.com" -Width 150 -Height 30 -PosX 100 -PosY 340
$HomepageTextBox.Font = New-Object System.Drawing.Font("Consolas",8,[System.Drawing.FontStyle]::Regular)

$groupBoxGeneral.Controls.AddRange(@(
    $GivenNameLabel,
    $GivenNameTextBox,
    $SurnameLabel,
    $SurnameTextBox,
    $InitialsLabel,
    $InitialsTextBox,
    $NameLabel,
    $NameTextBox,
    $DisplayNameLabel,
    $DisplayNameTextBox,
    $NameLabel,
    $NameComboBox,
    $DescriptionLabel,
    $DescriptionTextBox,
    $OfficeLabel,
    $OfficeComboBox,
    $OfficePhoneLabel,
    $OfficePhoneTextBox,
    $EmailAdressLabel,
    $EmailAdressTextBox,
    $HomepageLabel,
    $HomepageTextBox
))

#------------------------------------ create tab address----------------------------------------------------------------------------
$form.Controls.Add($groupBoxAddress)

$StreetAddressLabel = Create-Label -Name "StreetAddressLabel" -Content "Street Address" -Width 80 -Height 30 -PosX 20 -PosY 20
$StreetAddressTextBox = Create-TextBox -Name "StreetAddressTextBox" -Content "Musterstraße 13" -Width 150 -Height 30 -PosX 100 -PosY 20

$POBoxLabel = Create-Label -Name "POBoxLabel" -Content "Post Box" -Width 80 -Height 30 -PosX 20 -PosY 50
$POBoxTextBox = Create-TextBox -Name "POBoxTextBox" -Content "MusterBox" -Width 120 -Height 30 -PosX 100 -PosY 50

$CityLabel = Create-Label -Name "CityLabel" -Content "City" -Width 80 -Height 30 -PosX 20 -PosY 80
$CityTextBox = Create-TextBox -Name "CityTextBox" -Content "Koeln" -Width 120 -Height 30 -PosX 100 -PosY 80

$StateLabel = Create-Label -Name "StateLabel" -Content "State" -Width 80 -Height 30 -PosX 20 -PosY 110
$StateTextBox = Create-TextBox -Name "StateTextBox" -Content "Nord-Rhein-Westfalen" -Width 150 -Height 30 -PosX 100 -PosY 110

$PostalCodeLabel = Create-Label -Name "PostalCodeLabel" -Content "Postal Code" -Width 80 -Height 30 -PosX 20 -PosY 140
$PostalCodeTextBox = Create-TextBox -Name "PostalCodeTextBox" -Content "57235" -Width 120 -Height 30 -PosX 100 -PosY 140

$CountryLabel = Create-Label -Name "CountryLabel" -Content "Country" -Width 80 -Height 30 -PosX 20 -PosY 170
$CountryComboBox = Create-DropdownList -Name "CountryComboBox" -Form $form -List $countryList -Width 150 -Height 30 -PosX 100 -PosY 170

$groupBoxAddress.Controls.AddRange( @(
    $StreetAddressLabel,
    $StreetAddressTextBox,
    $POBoxLabel,
    $POBoxTextBox,
    $CityLabel,
    $CityTextBox,
    $StateLabel,
    $StateTextBox,
    $PostalCodeLabel,
    $PostalCodeTextBox,
    $CountryLabel,
    $CountryComboBox
    ))

<#---------------------------------- create tab account ------------------------------------------------------------------------------------
$form.Controls.Add($groupBoxAccount)
$UserPrincipal = Create-Label -Name "UserPrincipal" -Content "Login Name Domain" #username
$UserPrincipalNameTextBox = Create-TextBox -Name "UserPrincipalNameTextBox"

$groupBoxAccount.Controls.Add($UserPrincipal)
$groupBoxAccount.Controls.Add($UserPrincipalNameTextBox)

#---------------------------------- create sub-tab account options ---------------------------
$groupBoxAccount.Controls.Add($groupBoxAccountOptions)
$ChangePasswordAtLogonCheckBox = Create-CheckBox -Name "ChangePasswordAtLogonBox" -Title "Change Password At Logon"
$CannotChangePasswordCheckBox = Create-CheckBox -Name "CannotChangePasswordCheckBox" -Title "Cannot Change Password"
$PasswordNeverExpiresCheckBox = Create-CheckBox -Name "PasswordNeverExpiresCheckBox" -Title "Password Never Expires"
$EnabledCheckBox = Create-CheckBox -Name "EnabledCheckBox" -Title "Enable Account"

$groupBoxAccountOptions.controls.AddRange(@(
    $ChangePasswordAtLogonBox,
    $CannotChangePasswordCheckBox,
    $EnabledCheckBox
    ))

#passwordsection
$form.Controls.Add($groupBoxPassword)
$passwordLabel = Create-Label -Name "passwordLabel" -Content "Password"
$passwordTextBox = Create-TextBox -Name "passwordTextBox"

$groupBoxPassword.Controls.AddRange(@(
    $passwordLabel,
    $passwordTextBox
    ))
#>
#-------------------------------- User properties -------------------------------------------------------

#>
#$user.Initials = $user.GivenName.ToUpper()[0] + $user.Surname.ToUpper()[0]

#$user.Name = $user.GivenName.ToLower()[0] + $user.Surname.ToLower() #username

#$user.DisplayName = $user.GivenName + " " + $user.Surname

#$user.EmailAddress = "$($user.GivenName.ToLower()).$($user.Surname.ToLower())@soprasteria.com"

#$user.UserPrincipalName = $user.Name.ToString().ToLower() + "@azubi.dom" #UserLogonName

#---------------------- create and cancel buttons -----------------------------
#$form.Controls.Add($groupBoxControls)
#------------ control Buttons----------------------------------------
$okButton = Create-Button -ButtonName "createUserButton" -ButtonText "Create" -ButtonDockStyle ([System.Windows.Forms.DockStyle]::Bottom) -DialogResult ([Windows.Forms.DialogResult]::OK) -ButtonAction {
    #//TODO Actions to be performed when OK button is clicked
    $User = Write-User
    Write-Host "User Properties:"
    $User | Format-Table -AutoSize
    $form.Close()
    Write-Host "OK button clicked"
}
$cancelButton = Create-Button -ButtonName "cancelUserButton" -ButtonText "Cancel" -ButtonDockStyle ([System.Windows.Forms.DockStyle]::Bottom) -DialogResult ([Windows.Forms.DialogResult]::Cancel) -ButtonAction {
    #//TODO Actions to be performed when OK button is clicked
    $form.Close()
    Write-Host "Cancel button clicked"
}

$form.Controls.Add($okButton)
$form.Controls.Add($cancelButton)

#---------------------- edit groupBox ---------------------------------------


$form.Topmost = $true


$form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    #//TODO Get the user Input
    Write-Host "String from dropdown:"
}
elseif ($result -eq [System.Windows.Forms.DialogResult]::Cancel) {
    # Cancel button was clicked, perform necessary actions
    Write-Host "Performing actions based on Cancel button click..."
}