#!/bin/bash
testurl="https://aonprd.com/MonsterDisplay.aspx?ItemName=Dire%20Ape%20(Gigantopithecus)"
#"https://aonprd.com/MonsterDisplay.aspx?ItemName=Boar"
#Placeholder - eventually this'll be user provided

image="https://en.numista.com/catalogue/photos/tokens/34184-original.jpg"
#echo "https://aonprd.com/MonsterDisplay.aspx?ItemName=$1"
#sed s/\(/%28/g | sed s/\)/%29/g |
temp=$(echo "$1" | sed s/\'/%27/g | sed 's/ /%20/g' )
echo "$temp"
inputtext=$(curl "https://aonprd.com/MonsterDisplay.aspx?ItemName=$temp")
#echo $inputtext
nameregex="<h1 class=\"title\">(([a-z]|[A-Z]| |\)|\(|,)*)<\/h1>"
alignmentsizetyperegex="(LG|LN|LE|NG|N|NE|CG|CN|CE) (Fine|Diminutive|Tiny|Small|Medium|Large|Huge|Gargantuan|Colossal) (aberration|animal|construct|dragon|fey|humanoid|magical beast|monstrous humanoid|ooze|outsider|plant|undead|vermin)"
expregex="XP<\/b> ([0-9,]+)"
crregex="CR ([0-9/]+)"
initregex="Init<\/b> \+?([0-9-])"
sensesregex="Senses</b> ([a-z A-Z,-]*)"
acregex="AC<\/b> ([0-9]*), touch ([0-9]*), flat-footed ([0-9]*)"
#AC regex currently fails to retrieve the descriptor block, which will generally look something like (+<number> str, +<number> str>...)
#Below should capture it when appended to the existing acregex, but in fact breaks
#(?: \(([\+\-0-9 a-zAZ]*)\)<br)?
hpregex="hp<\/b> ([0-9]*) \(([0-9d\+]*)\)"
savesregex="Fort<\/b> \+?(-?[0-9]*), <b>Ref<\/b> \+?(-?[0-9]*), <b>Will<\/b> \+?(-?[0-9]*)"
defensesregex="Defensive Abilities<\/b> ([a-z, A-Z0-9\(\)]*)"
speedregex="Speed<\/b> ([0-9]* ft.)"
statsregex="Str<\/b> ([0-9]*), <b>Dex<\/b> ([0-9]*), <b>Con<\/b> ([0-9]*), <b>Int<\/b> ([0-9]*), <b>Wis<\/b> ([0-9]*), <b>Cha<\/b> ([0-9]*)"
babregex="Base Atk<\/b> \+([0-9]*)"
maneuverregex="CMB<\/b> \+([0-9]*); <b>CMD<\/b> ([0-9]*)"
#35 total skills
skillslabels=("acrobatics" "appraise" "bluff" "climb" "craft" "diplomacy" "disable_device" "disguise" "escape_artist" "fly" "handle_animal" "heal" "intimidate" "knowledge_arcana" "knowledge_dungeoneering" "knowledge_engineering" "knowledge_geography" "knowledge_history" "knowledge_local" "knowledge_nature" "knowledge_nobility" "knowledge_planes" "knowledge_religion" "linguistics" "perception" "perform" "profession" "ride" "sense_motive" "sleight_of_hand" "spellcraft" "stealth" "survival" "swim" "use_magic_device")
skillsstrings=("Acrobatics" "Appraise" "Bluff" "Climb" "Craft" "Diplomacy" "Disable Device" "Disguise" "Escape Artist" "Fly" "Handle Animal" "Heal" "Intimidate" "Knowledge \(Arcana\)" "Knowledge \(Dungeoneering\)" "Knowledge \(Engineering\)" "Knowledge \(Geography\)" "Knowledge \(History\)" "knowledge \(Local\)" "Knowledge \(Nature\)" "Knowledge \(Nobility\)" "Knowledge \(Planes\)" "Knowledge \(Religion\)" "Linguistics" "Perception" "Perform" "Profession" "Ride" "Sense Motive" "Sleight of Hand" "Spellcraft" "Stealth" "Survival" "Swim" "Use Magic Device")
spellsregexes=""
attacksregex="Melee<\/b> ([^<>]*)"


#function for computing the id of an entry; TODO
function get_id 
{
    echo ""
}
#tests and variable assignments:
[[ $inputtext =~ $nameregex ]]
echo "name:"
echo "${BASH_REMATCH[1]}"
name="${BASH_REMATCH[1]}"
[[ $inputtext =~ $alignmentsizetyperegex ]]
echo "alignment, size, type: "
echo "${BASH_REMATCH[1]} ${BASH_REMATCH[2]} ${BASH_REMATCH[3]}"
#echo "${BASH_REMATCH[2]}"
#echo "${BASH_REMATCH[3]}"
alignment="${BASH_REMATCH[1]}"
size="${BASH_REMATCH[2]}"
#For sizes larger than medium, may need to add logic for space and reach
#Ignoring that for now, though; mvp is simplest possible case
type="${BASH_REMATCH[3]}"
[[ $inputtext =~ $expregex ]]
#echo "EXP:"
#echo "${BASH_REMATCH[1]}"
exp="${BASH_REMATCH[1]}"
[[ $inputtext =~ $crregex ]]
echo "CR: ${BASH_REMATCH[1]} ($exp exp)"
#echo "${BASH_REMATCH[1]}"
cr="${BASH_REMATCH[1]}"
[[ $inputtext =~ $initregex ]]
echo "init: +${BASH_REMATCH[1]}"
#echo "${BASH_REMATCH[1]}"
init="${BASH_REMATCH[1]}"
[[ $inputtext =~ $sensesregex ]]
echo "senses: ${BASH_REMATCH[1]}"
#echo "${BASH_REMATCH[1]}"
senses="${BASH_REMATCH[1]}"
[[ $inputtext =~ $acregex ]]
echo "AC: ${BASH_REMATCH[1]} (${BASH_REMATCH[2]} touch, ${BASH_REMATCH[3]} Flat-footed)"
#echo "${BASH_REMATCH[1]}"
#echo "${BASH_REMATCH[2]}"
#echo "${BASH_REMATCH[3]}"
ac="${BASH_REMATCH[1]}"
touch="${BASH_REMATCH[2]}"
flat="${BASH_REMATCH[3]}"
[[ $inputtext =~ $hpregex ]]
echo "HP ${BASH_REMATCH[1]} (${BASH_REMATCH[2]})"
#echo "${BASH_REMATCH[1]}"
#echo "${BASH_REMATCH[2]}"
hp="${BASH_REMATCH[1]}"
hd="${BASH_REMATCH[2]}"
[[ $inputtext =~ $savesregex ]]
echo "saves: Fort +${BASH_REMATCH[1]}; Reflex +${BASH_REMATCH[1]}; Will +${BASH_REMATCH[1]}"
#echo "${BASH_REMATCH[1]}"
#echo "${BASH_REMATCH[2]}"
#echo "${BASH_REMATCH[3]}"
fort="${BASH_REMATCH[1]}"
reflex="${BASH_REMATCH[2]}"
will="${BASH_REMATCH[3]}"
if [[ $inputtext =~ $defensesregex ]]
then
    echo "Defensive abilities: ${BASH_REMATCH[1]}"
fi
    #echo "${BASH_REMATCH[1]}"
    defenses="${BASH_REMATCH[1]}"

[[ $inputtext =~ $speedregex ]]
echo "Speed: ${BASH_REMATCH[1]}"
#echo "${BASH_REMATCH[1]}"
speed="${BASH_REMATCH[1]}"
[[ $inputtext =~ $statsregex ]]
echo "Strength:${BASH_REMATCH[1]}"
echo "Dexterity: ${BASH_REMATCH[2]}"
echo "Constitution:${BASH_REMATCH[3]}"
echo "Intelligence: ${BASH_REMATCH[4]}"
echo "Wisdom: ${BASH_REMATCH[5]}"
echo "Charisma: ${BASH_REMATCH[6]}"
#echo "${BASH_REMATCH[1]}"
#echo "${BASH_REMATCH[2]}"
#echo "${BASH_REMATCH[3]}"
#echo "${BASH_REMATCH[4]}"
#echo "${BASH_REMATCH[5]}"
#echo "${BASH_REMATCH[6]}"
str="${BASH_REMATCH[1]}"
dex="${BASH_REMATCH[2]}"
con="${BASH_REMATCH[3]}"
int="${BASH_REMATCH[4]}"
wis="${BASH_REMATCH[5]}"
cha="${BASH_REMATCH[6]}"
[[ $inputtext =~ $babregex ]]
echo "Base Attack +${BASH_REMATCH[1]}"
#cho "${BASH_REMATCH[1]}"
bab="${BASH_REMATCH[1]}"
[[ $inputtext =~ $maneuverregex ]]
echo "CMB ${BASH_REMATCH[1]}; CMD:${BASH_REMATCH[2]}"
#echo "${BASH_REMATCH[1]}"
#echo "${BASH_REMATCH[2]}"
cmb="${BASH_REMATCH[1]}"
cmd="${BASH_REMATCH[2]}"
[[ $inputtext =~ $attacksregex ]]
echo "Attacks:"
echo "${BASH_REMATCH[1]}"
#perception is a special case; since it's used on token objects it needs to be handled as a skill and as an independent variable
percregex="Skills.*Perception \+([0-9]*)"
perception="0"
if [[ $inputtext =~ percregex ]] 
    then
    perception="${BASH_REMATCH[1]}"
fi
#Handling skills slightly differently, just on account of saving some repetition
for i in {0..34} 
    do
    
    skillregex="Skills.*${skillsstrings[$i]} \+([0-9]*)"
    if [[ $inputtext =~ $skillregex ]] 
        then
        echo "${skillslabels[$i]}: +${BASH_REMATCH[1]}"
        #echo "${BASH_REMATCH[1]}"
    fi
done

#Check whether the monster has melee attacks, then handle them
#attacks="\\\\\\"\\\\\\""
#Check whether the monster has ranged attacks, then handle them

#Check whether the monster has special attacks, then handle them

#Check whether the monster has spells or spell-like abilities, then handle those

#Check whether the monster has feats, then handle those
#feats="\\\\\\"\\\\\\""

#Once we have all the above, we just build up the json object with a pile of string operations

#A character entry is an object with the following keys - attributes: object, attribs: array of objects, blobBio: string, blobGmNotes: empty string, blobDefaultToken:string
#bio is some int; I've been totally unable to figure out how it's determined
#So I'm setting it to zero for now and seeing if that crashes anything
#Likewise defaulttoken
#attributesobj="\"attributes\": \{
#				\"name\": \""${$name}"\",
#				\"bio\": 0,
#				\"gmnotes\": \"\",
#				\"avatar\": \""${$image}"\",
#				\"inplayerjournals\": \"\",
#				\"controlledby\": \"\",
#				\"defaulttoken\": 0,
#				\"tags\": \"\",
#				\"archived\": false,
#				\"attrorder\": \"\",
#				\"abilorder\": \"\",
#				\"mancerdata\": \"\{\}\",
#				\"id\": \""${get_id $name}"\"
#			\},"
##This is a bunch of configuration stuff
##It doesn't depend on the monster being parsed, so all we need to do is create ids for everything
#configsobj="\{
#					\"name\": \"ask_modifier\",
#					\"current\": \"Modifier\",
#					\"max\": \"\",
#					\"id\": \""${get_id "ask_modifier$name"}"\"
#				\},
#				\{
#					\"name\": \"ask_atk_modifier\",
#					\"current\": \"Attack Modifier\",
#					\"max\": \"\",
#					\"id\": \""${get_id "ask_atk_modifier$name"}"\"
#				\},
#				\{
#					\"name\": \"ask_dmg_modifier\",
#					\"current\": \"Damage Modifier\",
#					\"max\": \"\",
#					\"id\": \""${get_id "ask_dmg_modifier$name"}"\"
#				\},
#				\{
#					\"name\": \"ask_whisper\",
#					\"current\": \"Whisper?\",
#					\"max\": \"\",
#					\"id\": \""${get_id "ask_whisper$name"}"\"
#				\},
#				\{
#					\"name\": \"ask_public_roll\",
#					\"current\": \"Public Roll\",
#					\"max\": \"\",
#					\"id\": \""${get_id "ask_public_roll$name"}"\"
#				\},
#				\{
#					\"name\": \"ask_whisper_roll\",
#					\"current\": \"Whisper Roll\",
#					\"max\": \"\",
#					\"id\": \""${get_id "ask_whisper_roll$name"}"\"
#				\},"
#nameattrib="\{
#					\"name\": \"npcdrop_name\",
#					\"current\": \""$name"\",
#					\"max\": \"\",
#					\"id\": \""${get_id "npcdrop_name$name"}"\"
#				\},"
##more config stuff.  Pretty sure order doesn't matter, but there's no documentation confirming that, so I'm not chancing it.
#categoryattrib="\{
#					\"name\": \"npcdrop_category\",
#					\"current\": \"Bestiary\",
#					\"max\": \"\",
#					\"id\": \"-M0OlOaIu_2imPRr3wyQ\"
#				\}"
##attrib that handles the token
##Need to write captures for treasure, environment, organization, ecology, description
#dataattrib="\{
#					\"name\": \"npcdrop_data\",
#					\"current\": \"\{\\\"Token\\\":\\\""$image"\\\",\\\"data-AC\\\":\\\"$ac\\\",\\\"data-CR\\\":\\\"$cr\\\",\\\"data-HP\\\":\\\"$hp\\\",\\\"data-XP\\\":\\\"$exp\\\",\\\"Category\\\":\\\"Bestiary\\\",\\\"data-CHA\\\":\\\"$cha\\\",\\\"data-CMB\\\":\\\"$cmb\\\",\\\"data-CMD\\\":\\\"$cmd\\\",\\\"data-CON\\\":\\\"$con\\\",\\\"data-DEX\\\":\\\"$dex\\\",\\\"data-INT\\\":\\\"$int\\\",\\\"data-Ref\\\":\\\"$ref\\\",\\\"data-STR\\\":\\\"$str\\\",\\\"data-WIS\\\":\\\"$wis\\\",\\\"Expansion\\\":\\\"8\\\",\\\"data-Fort\\\":\\\"$fort\\\",\\\"data-List\\\":\\\"false\\\",\\\"data-Size\\\":\\\"$size\\\",\\\"data-Type\\\":\\\""$type"\\\",\\\"data-Will\\\":\\\"$will\\\",\\\"data-Feats\\\":\\\"\["$feats"\]\\\",\\\"data-Speed\\\":\\\""$speed"\\\",\\\"data-Senses\\\":\\\""$senses"\\\",\\\"data-Attacks\\\":\\\"\[$attacks\]\\\",\\\"data-HP Roll\\\":\\\""$hd"\\\",\\\"icon-Climate\\\":\\\"Temperate\\\",\\\"icon-Terrain\\\":\\\"Forest\\\",\\\"data-AC Notes\\\":\\\"+4 natural\\\",\\\"data-AC Touch\\\":\\\"$touch\\\",\\\"data-Base Atk\\\":\\\"$bab\\\",\\\"data-Treasure\\\":\\\"none\\\",\\\"data-Alignment\\\":\\\"$alignment\\\",\\\"data-Initiative\\\":\\\"$init\\\",\\\"data-Perception\\\":\\\"$perception\\\",\\\"data-Description\\\":\\\""$desc"\\\",\\\"data-Environment\\\":\\\"temperate or tropical forests\\\",\\\"data-Organization\\\":\\\"solitary, pair, or group (3-8)\\\",\\\"icon-CreatureType\\\":\\\""$type"\\\",\\\"data-AC Flat-Footed\\\":\\\""$flat"\\\",\\\"data-Defensive Abilities\\\":\\\""$defenses"\\\\n\\\",\\\"blobs\\\":\{\}\}\",
#					\"max\": \"\",
#					\"id\": \""${get_id "npcdrop_data$name"}"\"
#				\},"
##Yet more config stuff
#				additionalinfo="\{
#					\"name\": \"npc\",
#					\"current\": 1,
#					\"max\": \"\",
#					\"id\": \"-M0OlOcAjDyVkwj_f2rj\"
#				\},
#				\{
#					\"name\": \"options-flag-npc\",
#					\"current\": 0,
#					\"max\": \"\",
#					\"id\": \"-M0OlOcCx6mBdZLIdIQW\"
#				\},
#				\{
#					\"name\": \"build-flag-npc\",
#					\"current\": 0,
#					\"max\": \"\",
#					\"id\": \"-M0OlOcDJCyNuCQ-eNPZ\"
#				\},
#				\{
#					\"name\": \"version\",
#					\"current\": 1.303,
#					\"max\": \"\",
#					\"id\": \"-M0OlOcIGqrBXVGIoply\"
#				\},
#				\{
#					\"name\": \"l1mancer_status\",
#					\"current\": \"completed\",
#					\"max\": \"\",
#					\"id\": \"-M0OlOcK1yKgZ_49XOcP\"
#				\},
#				\{
#					\"name\": \"npc_fromcompendium\",
#					\"current\": \"Bestiary:Boar\",
#					\"max\": \"\",
#					\"id\": \"-M0OlOcP1tfaNYTiXvhJ\"
#				\},
#				\{
#					\"name\": \"armor_spell_failure\",
#					\"current\": 0,
#					\"max\": \"\",
#					\"id\": \"-M0OlOcRZ0zzRvzLAh61\"
#				\},"