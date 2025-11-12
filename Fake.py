from faker import Faker

fake = Faker()
college_id_List = []
#Creating values for Fall25_S0003_T1_College
with open("TestInsert.sql", "w") as f:
    for _ in range(50):
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

with open("TestInsert.sql","+a") as f:
    for _ in range(50):
        name = fake.name().replace("'", "''")
        name_stripped = name.replace(" ", ".")
        email = name_stripped+"@edu.com"
        college_id = college_id_List[_]
        student_id = str(fake.random_int(min=1, max=99999999)).zfill(8)
        acad_status = fake.random_element(elements=("Associate", "Bachelor", "Masters", "PHD"))
        Major = fake.random_element(elements=("CS","Biology","Bussiness","History","Art","Lawyer","Nurse",""))

        insert_stmt = (
            f"INSERT INTO FALL25_S0003_T1_Student"
            f"(Name,Email,College_ID,Student_ID,Acad_Status,Major)"
            f"VALUES ('{name}','{email}','{college_id}','{student_id}','{acad_status}','{Major}');\n"
        )
        f.write(insert_stmt)