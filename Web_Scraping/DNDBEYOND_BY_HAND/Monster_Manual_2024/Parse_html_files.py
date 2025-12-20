import csv
import re
from bs4 import BeautifulSoup

# Sample HTML (replace with your actual HTML file if needed)
html_content = """
<div class="stat-block" data-content-chunk-id="792a2eae-5676-469c-a14a-e3bb87cf8941">
<h4 class="compendium-hr quick-menu-exclude heading-anchor" id="AarakocraAeromancerStatBlock" data-content-chunk-id="4542fa2f-5070-4510-a6f8-97bb1586d051"><a href="#AarakocraAeromancerStatBlock" data-content-chunk-id="81e3e421-d4f9-4abe-af84-31deb4b07b5a"></a><a class="tooltip-hover monster-tooltip" href="/monsters/5194864-aarakocra-aeromancer" data-tooltip-href="//www.dndbeyond.com/monsters/5194864-tooltip?disable-webm=1&amp;disable-webm=1">Aarakocra Aeromancer</a></h4>
<p data-content-chunk-id="002d3cbf-0398-42ef-9552-7e938169fc9b">Medium Elemental, Neutral</p>
<p data-content-chunk-id="d513a1a0-cec5-440e-99d8-d8cfeff68ebd"><strong>AC</strong> 16 <strong>Initiative</strong> +3 (13)</p>
<p data-content-chunk-id="49f9a4db-3432-451f-b836-504de81e0a59"><strong>HP</strong> 66 (12d8 + 12)</p>
<p data-content-chunk-id="2bc3a6bb-04b7-4a4b-9f6a-94674f38c014"><strong>Speed</strong> 20 ft., Fly 50 ft.</p>
...
<p class="monster-header" data-content-chunk-id="b7e34e88-d995-414b-b8f0-f3f71450209c">Actions</p>
<p data-content-chunk-id="0ef2dca8-0873-462b-8a23-19596ef2e358"><strong><em>Multiattack.</em></strong> The aarakocra makes two Wind Staff attacks, and it can use Spellcasting to cast <em>Gust of Wind</em>.</p>
<p data-content-chunk-id="976b9c1c-a6d0-41ec-957e-7d08ee050bfb"><strong><em>Wind Staff.</em></strong> <em>Melee or Ranged Attack Roll:</em> +5, reach 5 ft. or range 120 ft. <em>Hit:</em> 7 (1d8 + 3) Bludgeoning damage plus 11 (2d10) Lightning damage.</p>
<p class="monster-header" data-content-chunk-id="cb6e7895-2285-4002-b8c8-bccdeaa3427a">Bonus Actions</p>
<p data-content-chunk-id="86dd370c-21de-4a79-acc5-95dc02449282"><strong><em>Feather Fall (1/Day).</em></strong> The aarakocra casts <a class="tooltip-hover spell-tooltip" href="/spells/2618874-feather-fall" data-tooltip-href="//www.dndbeyond.com/spells/2618874-tooltip?disable-webm=1&amp;disable-webm=1">Feather Fall</a> in response to that spell’s trigger, using the same spellcasting ability as Spellcasting.</p>
<p class="monster-header" data-content-chunk-id="cb6e7895-2285-4002-b8c8-bccdeaa3427a">Legendary Actions</p>
<p data-content-chunk-id="86dd370c-21de-4a79-acc5-95dc02449282"><strong><em>Wing Buffet.</em></strong> The aarakocra makes a melee attack with its wings.</p>
</div>
"""

# Parse the HTML
soup = BeautifulSoup(html_content, "html.parser")

# Step 1: Extract basic information
stat_block = soup.select("div.stat-block")[0]
print(type(stat_block))
monster_name = stat_block.find("h4").text.strip()
print(f"Monster Name: {monster_name}")
size_type_alignment = stat_block.find("p").text.strip()
[ monster_size, monster_type, monster_alignment ] = re.split(r'[,\s]+', size_type_alignment)
print(f"Monster Size: {monster_size}")
print(f"Monster Type: {monster_type}")
print(f"Monster Alignment: {monster_alignment}")
exit


# Step 2: Extract AC, Initiative, HP, Speed
# ac_initiative = soup.find("p", string=lambda s: "AC" in s).text.strip().split(" ")
# Use CSS selector to find <p> tags containing <strong> with "AC"
# <p data-content-chunk-id="d513a1a0-cec5-440e-99d8-d8cfeff68ebd"><strong>AC</strong> 16 <strong>Initiative</strong> +3 (13)</p>
p_strong_tags = soup.select("p strong")
for tag in p_strong_tags:
    parent_p = tag.find_parent("p")
    if tag.string and "AC" in tag.string:
        if parent_p:
            # ac_initiative = parent_p.get_text(strip=True).split(" ")
            ac_initiative = parent_p.decode_contents()
            ac_initiative = re.replace(ac_initiative.replace(r'\</?strong\>','')
            print(f"Found AC Initiative: {ac_initiative}")
        else:
            print("<strong> tag with 'AC' is not inside a <p> tag.") 
    if tag.string and "HP" in tag.string:
        if parent_p:
            hp = parent_p.get_text(strip=True).split(" ")
            print(f"Found HP: {hp}")
        else:
            print("<strong> tag with 'HP' is not inside a <p> tag.") 
    if tag.string and "Speed" in tag.string:
        if parent_p:
            speed = parent_p.get_text(strip=True).split(" ")
            print(f"Found Speed: {speed}")
        else:
            print("<strong> tag with 'Speed' is not inside a <p> tag.") 

# ac = ac_initiative[1]
# initiative = ac_initiative[3]
# hp = hp_speed[0].text.strip().replace("HP ", "")
# speed = hp_speed[1].text.strip().replace("Speed ", "")

# Step 3: Extract ability scores and saves
abilities_saves = {}
for table in soup.find_all("table"):
    for row in table.find_all("tr"):
        cells = row.find_all(["th", "td"])
        if len(cells) == 4:
            ability = cells[0].text.strip()
            score = cells[1].text.strip()
            mod = cells[2].text.strip()
            save = cells[3].text.strip()
            abilities_saves[ability] = {"Score": score, "Modifier": mod, "Save": save}

# Step 4: Extract skills, senses, languages, CR
skills = soup.find("p", string=lambda s: "Skills" in s).text.strip().replace("Skills ", "")
senses = soup.find("p", string=lambda s: "Senses" in s).text.strip().replace("Senses ", "")
languages = soup.find("p", string=lambda s: "Languages" in s).text.strip().replace("Languages ", "")
cr = soup.find("p", string=lambda s: "CR" in s).text.strip().replace("CR ", "")

# Step 5: Extract traits, actions, bonus actions, legendary actions, reactions
traits = []
actions = []
bonus_actions = []
legendary_actions = []
reactions = []

current_section = None
for p in soup.find_all("p"):
    text = p.text.strip()
    if "Traits" in text:
        current_section = "traits"
    elif "Actions" in text and "Bonus" not in text and "Legendary" not in text:
        current_section = "actions"
    elif "Bonus Actions" in text:
        current_section = "bonus_actions"
    elif "Legendary Actions" in text:
        current_section = "legendary_actions"
    elif "Reactions" in text:
        current_section = "reactions"
    elif current_section == "traits":
        traits.append(text)
    elif current_section == "actions":
        actions.append(text)
    elif current_section == "bonus_actions":
        bonus_actions.append(text)
    elif current_section == "legendary_actions":
        legendary_actions.append(text)
    elif current_section == "reactions":
        reactions.append(text)

# Combine all data into a dictionary
monster_data = {
    "Name": name,
    "Size_Type_Alignment": size_type_alignment,
    "AC": ac,
    "Initiative": initiative,
    "HP": hp,
    "Speed": speed,
    "Abilities_Saves": abilities_saves,
    "Skills": skills,
    "Senses": senses,
    "Languages": languages,
    "CR": cr,
    "Traits": traits,
    "Actions": actions,
    "Bonus_Actions": bonus_actions,
    "Legendary_Actions": legendary_actions,
    "Reactions": reactions,
}

# Step 6: Export to CSV
csv_filename = "monster_stats.csv"

# Flatten the dictionary for CSV
flat_data = {
    "Name": monster_data["Name"],
    "Size_Type_Alignment": monster_data["Size_Type_Alignment"],
    "AC": monster_data["AC"],
    "Initiative": monster_data["Initiative"],
    "HP": monster_data["HP"],
    "Speed": monster_data["Speed"],
    **{f"{ability}_{key}": value for ability, stats in monster_data["Abilities_Saves"].items() for key, value in stats.items()},
    "Skills": monster_data["Skills"],
    "Senses": monster_data["Senses"],
    "Languages": monster_data["Languages"],
    "CR": monster_data["CR"],
    "Traits": "; ".join(monster_data["Traits"]),
    "Actions": "; ".join(monster_data["Actions"]),
    "Bonus_Actions": "; ".join(monster_data["Bonus_Actions"]),
    "Legendary_Actions": "; ".join(monster_data["Legendary_Actions"]),
    "Reactions": "; ".join(monster_data["Reactions"]),
}

# Write to CSV
with open(csv_filename, mode="w", newline="", encoding="utf-8") as file:
    writer = csv.DictWriter(file, fieldnames=flat_data.keys())
    writer.writeheader()
    writer.writerow(flat_data)

print(f"Data successfully written to {csv_filename}")
