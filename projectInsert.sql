BEGIN
  FOR i IN 1..50 LOOP
    INSERT INTO Fall25_S0003_T1_College (Name, College_ID, Phone, Email)
    VALUES (
      'College_' || i,
      LPAD(i, 8, '0'),
      '1234567890',
      'college' || i || '@edu.edu'
    );
  END LOOP;
  COMMIT;
END;
/