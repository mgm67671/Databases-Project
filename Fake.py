from faker import Faker
from datetime import datetime
import random

fake = Faker()
college_id_List = []
student_email_List = []
content_id_List = []
license_ID_List = []

#Creating values for Fall25_S0003_T1_College
# Reduced to 25 colleges so we can have more students per college
with open("projectDBinsert.sql", "w") as f:
    for _ in range(40):
        name = fake.city().replace("'", "''") + " University"
        college_id = str(fake.random_int(min=1, max=99999999)).zfill(8)
        phone = fake.msisdn()[:10]  # ensures numeric format, 12 digits max
        name_stripped = name.replace(" ", "")
        email = name_stripped+"@edu.com"
        college_id_List.append(college_id)
        insert_stmt = (
            f"INSERT INTO Fall25_S0003_T1_College "
            f"(Name, College_ID, Phone, Email) "
            f"VALUES ('{name}', '{college_id}', '{phone}', '{email}');\n"
        )
        f.write(insert_stmt)
    f.close()

# Creating values for Fall25_S0003_T1_Student
# Increased to 100 students, randomly distributed across 40 colleges (avg 2.5 per college)
with open("projectDBinsert.sql","+a") as f:
    for _ in range(100):
        name = fake.name().replace("'", "''")
        name_stripped = name.replace(" ", ".")
        email = name_stripped+"@edu.com"
        student_email_List.append(email)
        college_id = random.choice(college_id_List)  # Random college for more variety
        student_id = str(fake.random_int(min=1, max=99999999)).zfill(8)
        acad_status = fake.random_element(elements=("Associate", "Bachelor", "Masters", "PHD"))
        Major = fake.random_element(elements=("CS","Biology","Bussiness","History","Art","Lawyer","Nurse","NULL"))

        insert_stmt = (
            f"INSERT INTO FALL25_S0003_T1_Student"
            f"(Name,Email,College_ID,Student_ID,Acad_Status,Major)"
            f"VALUES ('{name}','{email}','{college_id}','{student_id}','{acad_status}','{Major}');\n"
        )
        f.write(insert_stmt)
    f.flush()
    f.close()

#Creating values for Fall25_S0003_T1_Content_Provider
# Reduced to 20 providers so each can have multiple licenses/content
with open("projectDBinsert.sql","+a") as f:
    for _ in range(40):
        name = fake.company()
        content_id = str(fake.random_int(min=1, max=99999999)).zfill(8)
        content_id_List.append(content_id)
        phone = fake.msisdn()[:10]
        name_stripped = name.replace(" ", ".").replace(",", "")
        email = name_stripped+"@bussines.com"
        
        insert_stmt = (
            f"INSERT INTO FALL25_S0003_T1_Content_Provider"
            f"(Name,Content_ID,Phone,Email)"
            f"VALUES ('{name}','{content_id}','{phone}','{email}');\n"
        )
        f.write(insert_stmt)
    f.flush()
    f.close()

#Creating values for Fall25_S0003_T1_License 
# Increased to 80 licenses across 40 providers (avg 2 licenses per provider)
with open("projectDBinsert.sql", "+a") as f:
    for _ in range(80):
        license_ID = str(fake.random_int(min=1, max=99999999)).zfill(8)
        license_ID_List.append(license_ID)
        Provider_ID = random.choice(content_id_List)  # Random provider for multiple licenses per provider
        license_type = fake.random_element(elements=("CC", "Fixed", "Royalty-Based", "Time-based","Revenue-sharing"))
        license_cost = fake.pricetag()
        SEndDate = datetime(2010,1,1)
        Start = fake.date_between('-30y',SEndDate)
        EStartDate = datetime(2011,1,1)
        End = fake.date_between(EStartDate)
        Renew_term = fake.random_element(elements=("NULL", "Contract Increase", "One time renewal", "No renewal","Automatic Renewal"))

        insert_stmt = (
            f"INSERT INTO FALL25_S0003_T1_License"
            f"(License_ID,Provider_ID,License_Type,License_Cost,Start_Date,End_Date,Renew_Terms)"
            f"VALUES ('{license_ID}','{Provider_ID}','{license_type}','{license_cost}',TO_DATE('{Start}', 'YYYY-MM-DD'), TO_DATE('{End}', 'YYYY-MM-DD'),'{Renew_term}');\n"
        )
        f.write(insert_stmt)
    f.flush()
    f.close()

#Creating values for Fall25_S0003_T1_Content
# Increased to 80 content items matching the 80 licenses
# Track the generated content IDs for later use
actual_content_id_List = []
with open("projectDBinsert.sql", "+a") as f:
    for _ in range(80):
        Title = fake.catch_phrase()
        content_id = str(fake.random_int(min=1, max=99999999)).zfill(8)
        actual_content_id_List.append(content_id)  # Track actual content IDs
        license_ID = license_ID_List[_]
        Maturity = fake.random_element(elements=("TV-Y", "TV-G", "TV-PG", "TV-14","TV-MA"))
        Type = fake.random_element(elements=("Seasons","Movie","TV Shows"))
        Seasons = fake.random_element(elements=("One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight"))
        Episodes = fake.random_element(elements=("1", "12", "24", "32", "60", "90", "120", "Cont"))
        Year = random.randint(2015,2025)  # Focus on recent years for Query 2
        Duration = fake.random_element(elements=("12", "24", "32", "60", "90", "120", "240", "300"))

        insert_stmt = (
            f"INSERT INTO FALL25_S0003_T1_Content"
            f"(Title,Content_ID,License_ID,Maturity,Type,Seasons,Episodes,Year,Duration)"
            f"VALUES ('{Title}', '{content_id}', '{license_ID}', '{Maturity}', '{Type}', '{Seasons}', '{Episodes}', '{Year}', '{Duration}');\n"
        )
        f.write(insert_stmt)
    f.flush()
    f.close()

#Creating values for Fall25_S0003_T1_Watch_History
# Generate 300 watch records with many-to-many relationships
# Each student can watch multiple content items, each content can be watched by multiple students
with open("projectDBinsert.sql", "+a") as f:
    attempted = 0
    successful = 0
    seen_pairs = set()
    
    while successful < 300 and attempted < 600:
        student_email = random.choice(student_email_List)
        content_id = random.choice(actual_content_id_List)
        
        # Check for unique student-content pair (due to UNIQUE constraint)
        pair_key = f"{student_email}_{content_id}"
        if pair_key not in seen_pairs:
            seen_pairs.add(pair_key)
            Watch_ID = str(fake.random_int(min=1, max=99999999)).zfill(8)
            Watch_time = fake.time(pattern="%H:%M:%S")
            SEndDate = datetime(2024,1,1)
            Start = fake.date_between(SEndDate)
            Device_Type = fake.random_element(elements=("Laptop","PC","Iphone","Android"))
            Duration = fake.random_element(elements=("12", "24", "32", "60", "90", "120", "240", "300"))
            
            insert_stmt = (
                f"INSERT INTO FALL25_S0003_T1_Watch_History"
                f"(Student_Email,Content_ID,Watch_ID,Watch_Time,Watch_Date,Device_Type,Duration)"
                f"VALUES ('{student_email}','{content_id}','{Watch_ID}','{Watch_time}',TO_DATE('{Start}', 'YYYY-MM-DD'),'{Device_Type}','{Duration}');\n"
            )
            f.write(insert_stmt)
            successful += 1
        attempted += 1
    f.flush()
    f.close()

#Creating values for Fall25_S0003_T1_Watches
# Generate 200 ratings that correspond to actual watches
with open("projectDBinsert.sql", "+a") as f:
    attempted = 0
    successful = 0
    seen_pairs = set()
    
    while successful < 200 and attempted < 400:
        student_email = random.choice(student_email_List)
        content_id = random.choice(actual_content_id_List)
        
        # Check for unique student-content pair
        pair_key = f"{student_email}_{content_id}"
        if pair_key not in seen_pairs:
            seen_pairs.add(pair_key)
            Rating = random.randint(1,10)
            
            insert_stmt = (
                f"INSERT INTO FALL25_S0003_T1_Watches"
                f"(Student_Email,Content_ID,Rating)"
                f"VALUES ('{student_email}','{content_id}','{Rating}');\n"
            )
            f.write(insert_stmt)
            successful += 1
        attempted += 1
    f.flush()
    f.close()

# Creating values for Fall25_S0003_T1_Favorite_Content
with open("projectDBinsert.sql", "+a") as f:
    for _ in range(80):
        content_id = random.choice(actual_content_id_List)
        student_email = random.choice(student_email_List)

        insert_stmt = (
            f"INSERT INTO FALL25_S0003_T1_Favorite_Content"
            f"(Content_ID,Student_Email)"
            f"VALUES ('{content_id}','{student_email}');\n"
        )
        f.write(insert_stmt)
    f.flush()
    f.close()

# Creating values for Fall25_S0003_T1_Favorite_Genre
with open("projectDBinsert.sql", "+a") as f:
    for _ in range(100):
        Genre = fake.random_element(elements=("Action","Drama","Romance","Adventure", "Thiller", "Mystery", "Comedy", "Western"))
        student_email = random.choice(student_email_List)

        insert_stmt = (
            f"INSERT INTO FALL25_S0003_T1_Favorite_Genre"
            f"(Genre,Student_Email)"
            f"VALUES ('{Genre}','{student_email}');\n"
        )
        f.write(insert_stmt)
    f.flush()
    f.close()

# Creating values for Fall25_S0003_T1_Partnership_Information
with open("projectDBinsert.sql", "+a") as f:
    for _ in range(40):
        SEndDate = datetime(2024,1,1)
        Start = fake.date_between(SEndDate)
        EStartDate = datetime(2025,1,1)
        EEndDate = datetime(2030,1,1)
        End = fake.date_between(EStartDate,EEndDate)
        license_cost = fake.pricetag()
        college_id = college_id_List[_]

        insert_stmt = (
            f"INSERT INTO Fall25_S0003_T1_Partnership_Information"
            f"(Start_Date,End_Date,Discount,College_ID)"
            f"VALUES (TO_DATE('{Start}', 'YYYY-MM-DD'), TO_DATE('{End}', 'YYYY-MM-DD'),'{license_cost}','{college_id}');\n"
        )
        f.write(insert_stmt)
    f.flush()
    f.close()

# Fall25_S0003_T1_Location
with open("projectDBinsert.sql", "+a") as f:
    for _ in range(40):
        State = fake.state_abbr()
        zipcode = fake.zipcode()
        city = fake.city().replace("'", "''")
        street = fake.street_address()
        college_id = college_id_List[_]

        insert_stmt = (
            f"INSERT INTO Fall25_S0003_T1_Location"
            f"(State,Zip_Code,City,Street_Address,College_ID)"
            f"VALUES ('{State}','{zipcode}','{city}','{street}','{college_id}');\n"
        )
        f.write(insert_stmt)
    f.flush()
    f.close()

# Fall25_S0003_T1_Genre
with open("projectDBinsert.sql", "+a") as f:
    for _ in range(80):
        Genre = fake.random_element(elements=("Action","Drama","Romance","Adventure", "Thiller", "Mystery", "Comedy", "Western"))
        content_id = actual_content_id_List[_]

        insert_stmt = (
            f"INSERT INTO Fall25_S0003_T1_Genre"
            f"(Genre,Content_ID)"
            f"VALUES ('{Genre}','{content_id}');\n"
        )
        f.write(insert_stmt)
    f.flush()
    f.close()

# Creating values for Fall25_S0003_T1_Language
with open("projectDBinsert.sql", "+a") as f:
    for _ in range(40):
        Language = fake.random_element(elements=("Spanish","English","French","Russian", "Portuguese", "German", "Hindi", "Arabic","Japanese","Korean"))
        content_id = actual_content_id_List[_]

        insert_stmt = (
            f"INSERT INTO Fall25_S0003_T1_Language"
            f"(Language,Content_ID)"
            f"VALUES ('{Language}','{content_id}');\n"
        )
        f.write(insert_stmt)
    f.flush()
    f.close()