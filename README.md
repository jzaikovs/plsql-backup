plsql-backup
=============

Skripts, lai automātiski saglabātu kopiju datubāzes kodam pie katras kompilācijas.
Ja ir vairāku cilvēku komanda tad dažreiz var gadīties,
ka vienlaicīgi tiek strādāts pie vienas un tās paša koda gabala. 
Kā viens nokompilē pakotni, funkciju, procedūru, tā otra izmaiņas pazūd, 
ja tā notiek tad no `plsql_archive` tabulas var dabūt iepriekšējās koda versijas.

Koda darbības princips:

Tiek izveidots shēmas trigeris `t_plsql_backup`.
Kā tiek pārkompilēts kāds shēmas objekts tā trigeris izpilda `plsql_backup.backup` procedūru,
kas saglabā izmainītā objekta kodu un tad atļauj jaunam izmaiņam uzstādīties serverī.
Tāpat tiek saglabātas visas `ALTER` un `DROP` izpildītās kommandas.

Instalācija
==============
skripta uzstādīšanas secība:

1) `table.sql`

2) `package.sql`

3) `trigger.sql`


TODO
==============

- [ ] Ieviest koda versiju salīdzināšanu, lai neglabātu kopiju vienādiem kodiem (piemēra, ja tiek pārkompilētas pakotnes no IVALID stāvokļa)