Import-Module ActiveDirectory

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

#$userProperties = Import-Csv -Delimiter "," -Path C:\Scripts\user_reg\Data\userdata.csv
$countryList = Import-Csv -Delimiter "," -Path C:\Scripts\user_reg\Data\country.csv
$officeList = @("Koeln", "Hamburg", "Sonstiges")


<#------------------------------ functions------------------------------------
these are in the "gui_test.ps1"
#>

function New-GroupBox {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Title,

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
    $groupBox.Location = New-Object System.Drawing.Point($PosX, $PosY)
    $groupBox.Size = New-Object System.Drawing.Size($Width, $Height)

    return $groupBox
}

function New-Label {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Content,

        [Parameter()]
        [int]$Width,
        [Parameter()]
        [int]$Height,

        [Parameter()]
        [int]$PosX,
        [Parameter()]
        [int]$PosY,

        [Parameter()]
        [ValidateSet('TopLeft', 'BottomLeft', 'TopRight', 'BottomRight')]
        [string]$Alignment = 'TopLeft'
    )

    $label = New-Object System.Windows.Forms.Label
    $label.Text = $Content

    $label.Location = New-Object System.Drawing.Point($PosX, $PosY)
    if ($Width -and $Height) {$label.Size = New-Object System.Drawing.Size($Width, $Height)}
    else {$label.AutoSize = $true}

    $alignmentMap = @{
        'TopLeft' = [System.Drawing.ContentAlignment]::TopLeft
        'BottomLeft' = [System.Drawing.ContentAlignment]::BottomLeft
        'TopRight' = [System.Drawing.ContentAlignment]::TopRight
        'BottomRight' = [System.Drawing.ContentAlignment]::BottomRight
    }
    $label.TextAlign = $alignmentMap[$Alignment]

    return $label
}

function New-TextBox {
    param (
        [Parameter()]
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
    $textBox.Location = New-Object System.Drawing.Point($PosX, $PosY)
    if ($Content) {$textBox.Text = $Content}

    if ($Width -and $Height) {$textBox.Size = New-Object System.Drawing.Size($Width, $Height)}
    else {$textBox.AutoSize = $true}

    return $textBox
}

function New-ComboBox {
    param (
        [Parameter(Mandatory=$true)]
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

    $comboBox = New-Object System.Windows.Forms.ComboBox
    $comboBox.Location = New-Object System.Drawing.Point($PosX, $PosY)

    $comboBox.DataSource = $List
    $comboBox.DisplayMember = "Name" #Displays only the name of the country

    $comboBox.Font = New-Object System.Drawing.Font("Lucida Console",10,[System.Drawing.FontStyle]::Regular)

    if ($Width -and $Height) {$comboBox.Size = New-Object System.Drawing.Size($Width, $Height)}
    else {$comboBox.AutoSize = $true}

    return $comboBox
}

function New-CheckBox {
    param (
        [Parameter(Mandatory = $true)]
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
    $checkBox.Text = $Title

    $checkBox.Location = New-Object System.Drawing.Point($PosX, $PosY)

    #adds the width and height if given
    if ($Width -and $Height) {$checkBox.Size = New-Object System.Drawing.Size($Width, $Height)}
    else {$checkBox.AutoSize = $true}

    return $checkBox
}

function New-Button {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ButtonText,

        [Parameter()]
        [int]$PosX,
        [Parameter()]
        [int]$PosY
    )

    $button = New-Object System.Windows.Forms.Button
    $button.Text = $ButtonText

    if ($PosX -and $PosY) {$button.Location = New-Object System.Drawing.Point($PosX,$PosY)}
    else {$button.Dock = [System.Windows.Forms.DockStyle]::Bottom}

    return $button
}

function Get-Country {
    param (
        [Parameter()]
        [string]$Country
    )

    try {

        $matchingCountry = $countryList | Where-Object { $_.Name -eq $Country } # matching pair wird gesucht

        if ($matchingCountry) {

            return @{c = $matchingCountry.Value; co = $matchingCountry.Name}

        } else {

            throw "No matching country found."

        }

    } catch {

        #Start-Job -ScriptBlock $SpeakToUser -ArgumentList "Kein gültiges Land"
        Write-Host -ForegroundColor Red "There is no such country."

    }
    
}

function New-Password {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [ValidateRange(6, [int]::MaxValue)]
        [int]$Length = 6
    )

    if ($Length -lt 6) {
        throw "Password length must be at least 6 characters."
    }
    elseif ($Length -gt 20) {
        throw "Password length cannot exceed 20 characters."
    }

    #ASCII Character set for Password
    $CharacterSet = @{
            Uppercase   = (97..122) | Get-Random -Count $Length | % {[char]$_}
            Lowercase   = (65..90)  | Get-Random -Count $Length | % {[char]$_}
            Numeric     = (48..57)  | Get-Random -Count $length | % {[char]$_}
            SpecialChar = (33..47)+(58..64)+(91..96)+(123..126) | Get-Random -Count 10 | % {[char]$_}
    }

    #Frame Random Password from given character set
    $StringSet = $CharacterSet.Uppercase + $CharacterSet.Lowercase + $CharacterSet.Numeric + $CharacterSet.SpecialChar

    $password = -join(Get-Random -Count $Length -InputObject $StringSet)
    [System.Windows.Forms.MessageBox]::Show("Your password:`n$password`n`nPlease write it down!","Password",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Information)
    
    $securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force
    return $securePassword
}

function Set-AccountExpirationdate {
    
    if (!($AccountExpirationDatePicker.Checked)) {
        return $null
    }else {return $AccountExpirationDatePicker.Value}
    
}

#----------------------- create form ---------------------------------------------
#$form = New-Form -Title "New AD User" -Name "ADUserGUI" -StartPosition "Centerscreen" -Width 1000 -Height 730
$form = New-Object System.Windows.Forms.Form
$form.Text = "New AD-User"
$form.Size = New-Object System.Drawing.Size(1000, 730)
$form.StartPosition = "Centerscreen"
$form.Topmost = $true


#---------------------- create Groupboxes ----------------------------------------
$groupBoxGeneral = New-GroupBox -Title "General" -Width 270 -Height 375 -PosX 20 -PosY 20 # GroupBox um den Allgemein Tab ein zugeben
$groupBoxAddress = New-GroupBox -Title "Address" -Width 270 -Height 210 -PosX 20 -PosY 420 # GroupBox um den Adress Tab ein zu geben
$groupBoxAccount = New-GroupBox -Title "Account" -Width 270 -Height 280 -PosX 315 -PosY 20 # GroupBox um den Konto Tab ein zu geben
$groupBoxAccountOptions = New-GroupBox -Title "Account Options" -Width 250 -Height 150 -PosX 10 -PosY 70 # GroupBox um die Konto Optionen ein zu geben
$groupBoxPassword = New-GroupBox -Title "Password" -Width 270 -Height 60 -PosX 315 -PosY 330 # GroupBox um den Passwort Tab ein zu geben
#$groupBoxMiscellaneous = New-GroupBox -Title "Miscellaneous" # GroupBox um Verschiedenes ein zu geben
#$groupBoxControls = New-GroupBox -Title "" -Width 830 -Height 30 -PosX 10 -PosY 970

#------------------------------ create tab general -----------------------------------

$GivenNameLabel = New-Label -Content "First Name" -Width 80 -Height 30 -PosX 20 -PosY 20
$GivenNameTextBox = New-TextBox -Content "Fritz" -Width 120 -Height 30 -PosX 100 -PosY 20

$SurnameLabel = New-Label -Content "Surname" -Width 80 -Height 30 -PosX 20 -PosY 50
$SurnameTextBox = New-TextBox -Content "Meier" -Width 120 -Height 30 -PosX 100 -PosY 50

$InitialsLabel = New-Label -Content "Initials" -Width 80 -Height 30 -PosX 20 -PosY 80
$InitialsTextBox = New-TextBox -Content "FM" -Width 25 -Height 30 -PosX 100 -PosY 80

$NameLabel = New-Label -Content "Username" -Width 80 -Height 30 -PosX 20 -PosY 110
$NameTextBox = New-TextBox -Content "fritzmeier" -Width 120 -Height 30 -PosX 100 -PosY 110

$DisplayNameLabel = New-Label -Content "Displayname" -Width 80 -Height 30 -PosX 20 -PosY 140
$DisplayNameTextBox = New-TextBox -Content "Fritz Meier" -Width 120 -Height 30 -PosX 100 -PosY 140

$DescriptionLabel = New-Label -Content "Description" -Width 80 -Height 30 -PosX 20 -PosY 170
$DescriptionTextBox = New-TextBox -Content "This is a description." -Width 150 -Height 70 -PosX 100 -PosY 170
$DescriptionTextBox.Multiline = $true

$OfficeLabel = New-Label -Content "Office" -Width 80 -Height 30 -PosX 20 -PosY 250
$OfficeComboBox = New-ComboBox -List $officeList -Width 120 -Height 30 -PosX 100 -PosY 250

$OfficePhoneLabel = New-Label -Content "Office Phone" -Width 80 -Height 30 -PosX 20 -PosY 280
$OfficePhoneTextBox = New-TextBox -Content "0123456789" -Width 120 -Height 30 -PosX 100 -PosY 280

$EmailAdressLabel = New-Label -Content "Email" -Width 80 -Height 30 -PosX 20 -PosY 310
$EmailAdressTextBox = New-TextBox -Content "fritz.meier@soprasteria.com" -Width 150 -Height 30 -PosX 100 -PosY 310
$EmailAdressTextBox.Font = New-Object System.Drawing.Font("Consolas",8,[System.Drawing.FontStyle]::Regular)

$HomepageLabel = New-Label -Content "Website" -Width 80 -Height 30 -PosX 20 -PosY 340
$HomepageTextBox = New-TextBox -Content "www.fritz-meier.com" -Width 150 -Height 30 -PosX 100 -PosY 340
$HomepageTextBox.Font = New-Object System.Drawing.Font("Consolas",8,[System.Drawing.FontStyle]::Regular)

$form.Controls.Add($groupBoxGeneral)
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

$StreetAddressLabel = New-Label -Content "Street Address" -Width 80 -Height 30 -PosX 20 -PosY 20
$StreetAddressTextBox = New-TextBox -Content "Musterstraße 13" -Width 150 -Height 30 -PosX 100 -PosY 20

$POBoxLabel = New-Label -Content "Post Box" -Width 80 -Height 30 -PosX 20 -PosY 50
$POBoxTextBox = New-TextBox -Content "MusterBox" -Width 120 -Height 30 -PosX 100 -PosY 50

$CityLabel = New-Label -Content "City" -Width 80 -Height 30 -PosX 20 -PosY 80
$CityTextBox = New-TextBox -Content "Koeln" -Width 120 -Height 30 -PosX 100 -PosY 80

$StateLabel = New-Label -Content "State" -Width 80 -Height 30 -PosX 20 -PosY 110
$StateTextBox = New-TextBox -Content "Nord-Rhein-Westfalen" -Width 150 -Height 30 -PosX 100 -PosY 110

$PostalCodeLabel = New-Label -Content "Postal Code" -Width 80 -Height 30 -PosX 20 -PosY 140
$PostalCodeTextBox = New-TextBox -Content "57235" -Width 120 -Height 30 -PosX 100 -PosY 140

$CountryLabel = New-Label -Content "Country" -Width 80 -Height 30 -PosX 20 -PosY 170
$CountryComboBox = New-ComboBox -List $countryList -Width 150 -Height 30 -PosX 100 -PosY 170

$form.Controls.Add($groupBoxAddress)
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

#---------------------------------- create tab account ------------------------------------------------------------------------------------
$form.Controls.Add($groupBoxAccount)
$UserPrincipal = New-Label -Content "Login Name Domain" -Width 80 -Height 30 -PosX 20 -PosY 20 #username
$UserPrincipalNameTextBox = New-TextBox -Content "f.meier" -Width 120 -Height 30 -PosX 100 -PosY 20

#the $accountOptionGroupBox is right here

$AccountExpirationDateLabel = New-Label -Content "Expiration Date" -Width 80 -Height 30 -PosX 20 -PosY 240
# Create a date input field
$AccountExpirationDatePicker = New-Object System.Windows.Forms.DateTimePicker
$AccountExpirationDatePicker.Location = New-Object System.Drawing.Point(100,240)
$AccountExpirationDatePicker.Size = New-Object System.Drawing.Size(150,30)
$AccountExpirationDatePicker.Format = [System.Windows.Forms.DateTimePickerFormat]::Short
$AccountExpirationDatePicker.ShowCheckBox = $true
$AccountExpirationDatePicker.Checked = $false

$groupBoxAccount.Controls.AddRange( @(
    $UserPrincipal,
    $UserPrincipalNameTextBox,
    $AccountExpirationDateLabel,
    $AccountExpirationDatePicker
    ))

#---------------------------------- create sub-tab account options ---------------------------
$groupBoxAccount.Controls.Add($groupBoxAccountOptions)
$ChangePasswordAtLogonCheckBox = New-CheckBox -Title "Change Password At Logon" -Width 200 -Height 30 -PosX 20 -PosY 20
$CannotChangePasswordCheckBox = New-CheckBox -Title "Cannot Change Password" -Width 200 -Height 30 -PosX 20 -PosY 50
$PasswordNeverExpiresCheckBox = New-CheckBox -Title "Password Never Expires" -Width 200 -Height 30 -PosX 20 -PosY 80
$EnabledCheckBox = New-CheckBox -Title "Enable Account" -Width 200 -Height 30 -PosX 20 -PosY 110

$groupBoxAccountOptions.Controls.AddRange(@(
    $ChangePasswordAtLogonCheckBox,
    $CannotChangePasswordCheckBox,
    $PasswordNeverExpiresCheckBox,
    $EnabledCheckBox
    ))

#passwordsection
$passwordLabel = New-Label -Content "Passwordlength" -Width 85 -Height 30 -PosX 20 -PosY 20

$passwordLengthUpDown = New-Object System.Windows.Forms.NumericUpDown
$passwordLengthUpDown.Minimum = 6
$passwordLengthUpDown.Maximum = 20
$passwordLengthUpDown.Value = 8 #default Value
$passwordLengthUpDown.Location = New-Object System.Drawing.Point(105,20)
$passwordLengthUpDown.Size = New-Object System.Drawing.Size(50,30)

$passwordButton = New-Button -ButtonText "Generate Password" -PosX 170 -PosY 20


$form.Controls.Add($groupBoxPassword)
$groupBoxPassword.Controls.AddRange(@(
    $passwordLabel,
    $passwordLengthUpDown,
    $passwordButton
    ))

#-------------------------------- User properties -------------------------------------------------------

#---------------------- create and cancel buttons -----------------------------


$okButton = New-Button -ButtonText "Create"
$okButton.DialogResult = ([Windows.Forms.DialogResult]::OK)

$cancelButton = New-Button -ButtonText "Cancel"
$cancelButton.DialogResult = ([Windows.Forms.DialogResult]::Cancel)

$form.Controls.Add($okButton)
$form.Controls.Add($cancelButton)

#---------------------- edit groupBox ---------------------------------------

# Show the form and get user input


# Store the user input in a variable to use later

$User = [ordered]@{
    GivenName = $GivenNameTextBox.Text
    Surname = $SurnameTextBox.Text
    Initials = $InitialsTextBox.Text
    Name = $NameTextBox.Text #Username
    DisplayName = $DisplayNameTextBox.Text
    Description = $DescriptionTextBox.Text
    Office = $OfficeComboBox.Text
    OfficePhone = $OfficePhoneTextBox.Text
    EmailAddress = $EmailAdressTextBox.Text
    HomePage = $HomepageTextBox.Text

    StreetAddress = $StreetAddressTextBox.Text
    POBox = $POBoxTextBox.Text
    City = $CityTextBox.Text
    State = $StateTextBox.Text
    PostalCode = $PostalCodeTextBox.Text
    Country = $null

    UserPrincipalName = $UserPrincipalNameTextBox.Text
    AccountExpirationDate = $null

    ChangePasswordAtLogon = $ChangePasswordAtLogonCheckBox.Checked
    CannotChangePassword = $CannotChangePasswordCheckBox.Checked
    PasswordNeverExpires = $PasswordNeverExpiresCheckBox.Checked
    Enabled = $EnabledCheckBox.Checked

    AccountPassword = $null
}

$passwordButton.Add_Click({
    $User.AccountPassword = New-Password -Length $passwordLengthUpDown.Value
})

$okButton.Add_Click({
    $User.AccountExpirationDate = Set-AccountExpirationdate
    if ($User.AccountPassword -eq $null) {$User.AccountPassword = New-Password -Length $passwordLengthUpDown.Value}
    [System.Windows.Forms.MessageBox]::Show("User creation '" + $User.DisplayName + "' successful.","New AD-User",0,[System.Windows.Forms.MessageBoxIcon]::Information)
    Write-Host -f DarkCyan $OfficeComboBox.Text
})

$cancelButton.Add_Click({$form.Close()})

$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    try {
        New-ADUser @User
        $User
        Write-Host -f Green $User.DisplayName "creation successful"
    }
    catch {Write-Host -f Red "Something went wrong. Could not create User"}
    try {
    $countryName = $CountryComboBox.Text
    Set-ADUser -Identity $User.Name -Replace (Get-Country -Country $countryName)
    }
    catch {
        Write-Host -f Red "Could not set Country"
    }
}
elseif ($result -eq [System.Windows.Forms.DialogResult]::Cancel) {
    # Cancel button was clicked, perform necessary actions
    Write-Host -f DarkYellow "creation canceled"
}