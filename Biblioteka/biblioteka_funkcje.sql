CREATE FUNCTION dodaj_mies(start DATE, miesiace INT)
RETURNS DATE AS
$$
  SELECT(start+(miesiace||' mies.')::INTERVAL)::DATE
$$
LANGUAGE sql IMMUTABLE;
-----------------------
CREATE OR REPLACE FUNCTION rezerwacja(id_k INT, id_u INT)
RETURNS INT AS
$$
BEGIN
	INSERT INTO Rezerwacje(id_ksiazki, id_uzytkownika, data_rezerwacji, data_wygasniecia_rezerw) VALUES (id_k, id_u, CURRENT_DATE, dodaj_mies(CURRENT_DATE, 1));
END;
$$
LANGUAGE plpgsql;
-----------------
CREATE OR REPLACE FUNCTION znajdz_mies(id_u INT)
RETURNS INT AS
$$
DECLARE
	wyp_mies INT;
BEGIN
	SELECT mies_wyp_ks
	INTO wyp_mies
	FROM Limity
	WHERE rank IN (SELECT stopien FROM Studenci WHERE id_studenta=id_u);
	RETURN loan_months;
END;
$$
LANGUAGE plpgsql;
-----------------
CREATE OR REPLACE FUNCTION wypozyczanie(id_k INT, id_u INT)
RETURNS INT AS
$$
DECLARE
	data_zwrotu DATE;
	limit_k INT;
	liczba_wypoz INT;
BEGIN
	data_zwrotu:=dodaj_mies(CURRENT_DATE, znajdz_mies(id_u));
	limit_k:=(SELECT max_ksiazek FROM Limity WHERE status=(SELECT stopien FROM Studenci WHERE id_studenta=id_u));
	liczba_wypoz:=(SELECT COUNT(id_wypozyczenia) FROM Wypozyczenia WHERE id_uzytkownika=id_u);
	
	IF EXISTS(SELECT 1 FROM Wypozyczenia WHERE id_ksiazki=id_k AND data_zwrotu>=CURRENT_DATE AND liczba_wypoz<limit_k) THEN
		ROLLBACK;
		RAISE EXCEPTION 'Książka nie jest dostępna';
	END IF;

	INSERT INTO Wypozyczenia(id_ksiazki, id_uzytkownika, data_wyp, data_zwr) VALUES (id_k, id_u, CURRENT_DATE, data_zwrotu);
	RETURN 1;
END;
$$ LANGUAGE plpgsql;
--------------------
CREATE OR REPLACE FUNCTION zwrot(id_k INT)
RETURNS VOID AS
$$
BEGIN
	DELETE FROM Wypozyczenia WHERE id_ksiazki=id_k;
END;
$$ LANGUAGE plpgsql;
--------------------
CREATE OR REPLACE FUNCTION kara_przetrzymanie(id_k INT, id_u INT)
RETURNS INT AS
$$
DECLARE
	roznica_d INT;
	kara INT;
BEGIN
	roznica_d:=CURRENT_DATE-(SELECT data_zwr FROM Wypozyczenia WHERE id_ksiazki=id_k);

	IF roznica_d>0 THEN
		kara:=roznica_d*0.4;
		INSERT INTO Kary(id_uzytkownika, kwota, data_naliczenia) VALUES (id_u, kara, CURRENT_DATE);
		RETURN 1;
	ELSE
		RAISE EXCEPTION 'Kara nie może zostać naliczona';
		RETURN 0;
	END IF;
END;
$$ LANGUAGE plpgsql;