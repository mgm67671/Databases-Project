from faker import Faker
import oracledb

try:
    fake = Faker()
    connection = oracledb.connect(user='',password='',dsn='')
    cursor = connection.cursor()

    for _ in range(1):
        cursor.execute("""INSERT INTO Fall25_S0003_T1_Student(
                       Name, Email, College_ID, Student_ID, Acad_status, Major)
                       VALUES (:1,:2,:3,:4,:5,:6)""",(fake.name(),
                                                      fake.email(),
                                                      fake.random_number(digits=8),
                                                      fake.random_number(digits=8),
                                                      fake.random_element(elements=('Active', 'Inactive')),
                                                      fake.random_element(elements=('CS', 'Math','Biology'))))
        
        connection.commit()
        connection.close()
except oracledb.Error as e:
    print(f"Error connecting to Oracle Database: {e}")