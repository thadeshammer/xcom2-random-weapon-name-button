/*
	Adds the titular button to the top left of the Armory's weapon modification UI.

	Previous iterations had a critical mystery bug that rendered the defaultproperties
	ScreenClass setting inert, which prevented me from (cleanly) using local references
	to a given weapon; this prevented the button from working with other mods that
	added new weapons or allowed renaming of secondary weapons. Special thanks to
	steamuser /dev/null who figured this out and lead me through the fix!
*/

class RandomWeaponNameButton extends UIScreenListener;

var localized string			m_strGeneratedNickNotSupported;

var UIButton					RandomWeaponNickNameButton;
var UIArmory_WeaponUpgrade		WeaponModScreen;

delegate OnClickedDelegate(UIButton Button);

const BUTTON_FONT_SIZE		= 26;
const BUTTON_HEIGHT			= 34;

event OnInit(UIScreen Screen)
{
	local string		strRandomWeaponNickNameButtonLabel;
	local string		strWeaponNickNameTooltip;
	local string		strNewNickName;

	WeaponModScreen = UIArmory_WeaponUpgrade(Screen);

	if (WeaponModScreen == none)
		return;

	m_strGeneratedNickNotSupported = "Can't generate name for this weapon.";

	RandomWeaponNickNameButton = CreateButton(WeaponModScreen, 'WeaponNameButton', "Random Weapon Nickname", GenerateRandomWeaponName, class'UIUtilities'.const.ANCHOR_TOP_LEFT, 70, 75);
	strNewNickName = XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(WeaponModScreen.WeaponRef.ObjectID)).GenerateNickname();

	if (strNewNickName == "")
	{
		strRandomWeaponNickNameButtonLabel = class'UIUtilities_Text'.static.GetColoredText("Random Weapon Nickname", eUIState_Disabled);
		strWeaponNicknameTooltip = m_strGeneratedNickNotSupported;
		RandomWeaponNicknameButton.SetDisabled(true, strWeaponNicknameTooltip);
	} else {
		strRandomWeaponNickNameButtonLabel = class'UIUtilities_Text'.static.GetColoredText("Random Weapon Nickname", eUIState_Normal);
	}	
	
}


simulated function UIButton CreateButton(UIScreen Screen, 
										 name ButtonName, string ButtonLabel,
										 delegate<OnClickedDelegate> OnClickCallThis, 
										 int AnchorPos, int XOffset, int YOffset)
{
	local UIButton NewButton;

	NewButton = Screen.Spawn(class'UIButton', Screen);
	NewButton.InitButton(ButtonName, class'UIUtilities_Text'.static.GetSizedText(ButtonLabel, BUTTON_FONT_SIZE), OnClickCallThis);
	NewButton.SetAnchor(AnchorPos);
	NewButton.SetPosition(XOffset, YOffset);
	NewButton.SetSize(NewButton.Width, BUTTON_HEIGHT);
	
	return NewButton;
}

simulated function GenerateRandomWeaponName(UIButton Button)
{
	local StateObjectReference			WeaponRef;
	local XComGameState_Item			Weapon;
	local string						NewNickName;	
		
	WeaponRef = WeaponModScreen.WeaponRef;

	Weapon = XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(WeaponRef.ObjectID));

	NewNickName = Weapon.GenerateNickname();
	Weapon.Nickname = NewNickName;

	WeaponModScreen.UpdateSlots();
}

defaultproperties
{
	ScreenClass = class'UIArmory_WeaponUpgrade';
}