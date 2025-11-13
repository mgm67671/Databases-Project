from faker import Faker
from datetime import datetime

fake = Faker()
college_id_List = []
student_email_List = []
content_id_List = []

#Creating values for Fall25_S0003_T1_College
with open("TestInsert.sql", "w") as f:
    for _ in range(10):
        name = fake.city().replace("'", "''") + " University"
        college_id = str(fake.random_int(min=1, max=99999999)).zfill(8)
        phone = fake.msisdn()[:10]  # ensures numeric format, 12 digits max
        name_stripped = name.replace(" ", "")
        email = name_stripped+"@edu.com"
        #email = fake.email()
        college_id_List.append(college_id)
        insert_stmt = (
            f"INSERT INTO Fall25_S0003_T1_College "
            f"(Name, College_ID, Phone, Email) "
            f"VALUES ('{name}', '{college_id}', '{phone}', '{email}');\n"
        )
        f.write(insert_stmt)
    f.close()

#Creating values for Fall25_S0003_T1_Studnet
with open("TestInsert.sql","+a") as f:
    for _ in range(10):
        name = fake.name().replace("'", "''")
        name_stripped = name.replace(" ", ".")
        email = name_stripped+"@edu.com"
        student_email_List.append(email)
        college_id = college_id_List[_]
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
with open("TestInsert.sql","+a") as f:
    for _ in range(10):
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

with open("TestInsert.sql", "+a") as f:
    for _ in range(10):
        license_ID = str(fake.random_int(min=1, max=99999999)).zfill(8)
        Provider_ID = content_id_List[_]
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