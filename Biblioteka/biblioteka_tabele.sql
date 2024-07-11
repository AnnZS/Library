CREATE TABLE Ksiazki
(
	id_ksiazki SERIAL PRIMARY KEY,
	tytul VARCHAR(50),
	autor VARCHAR(30),
	rok_wyd INT,
	wydawnictwo VARCHAR(50),
	ISBN CHAR(13)
);

CREATE TABLE Studenci
(
	id_studenta SERIAL PRIMARY KEY,
	imie VARCHAR(20),
	nazwisko VARCHAR(30),
	e_mail VARCHAR(35),
	stopien VARCHAR(20)
);

CREATE TYPE status_uzytkownika AS ENUM ('licencjat', 'magister', 'doktorant');

CREATE TABLE Limity
(
  	status status_uzytkownika,
	max_ksiazek INT,
  	mies_wyp_ks INT
);

CREATE TABLE Wypozyczenia
(
	id_wypozyczenia SERIAL PRIMARY KEY,
	id_ksiazki INT,
	id_uzytkownika INT,
	data_wyp DATE,
	data_zwr DATE,
	status status_uzytkownika,
	FOREIGN KEY(id_uzytkownika) REFERENCES Studenci(id_studenta) ON DELETE CASCADE,
	FOREIGN KEY(id_ksiazki) REFERENCES Ksiazki(id_ksiazki) ON DELETE CASCADE
);

CREATE TABLE Rezerwacje
(
	id_rezerwacji SERIAL PRIMARY KEY,
	id_ksiazki INT,
	id_uzytkownika INT,
	data_rezerwacji DATE,
	data_wygasniecia_rezerw DATE,
	FOREIGN KEY(id_uzytkownika) REFERENCES Studenci(id_studenta) ON DELETE CASCADE,
	FOREIGN KEY(id_ksiazki) REFERENCES Ksiazki(id_ksiazki) ON DELETE CASCADE
);

CREATE TABLE Kary
(
	id_kary SERIAL PRIMARY KEY,
	id_uzytkownika INT,
	kwota INT,
	data_naliczenia DATE,
	FOREIGN KEY(id_uzytkownika) REFERENCES Studenci(id_studenta) ON DELETE CASCADE
);