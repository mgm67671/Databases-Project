from faker import Faker

fake = Faker()
#Creating values for Fall25_S0003_T1_College
with open("TestInsert.sql", "w") as f:
    for _ in range(50):
        name = fake.city().replace("'", "''") + " University"
        college_id = str(fake.random_int(min=1, max=99999999)).zfill(8)
        phone = fake.msisdn()[:10]  # ensures numeric format, 12 digits max
        name_stripped = name.replace(" ", "")
        email = name_stripped+"@edu.com"
        #email = fake.email()

        insert_stmt = (
            f"INSERT INTO Fall25_S0003_T1_College "
            f"(Name, College_ID, Phone, Email) "
            f"VALUES ('{name}', '{college_id}', '{phone}', '{email}');\n"
        )
        f.write(insert_stmt)
    f.close()

