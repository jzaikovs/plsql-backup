plsql-backup
=============

Mazs noderīgs skripts, lai automātiski saglabātu kopiju datubāzes kodam pie katras kompilācijas.
Ja ir vairāku cilvēku komanda tad dažreiz var gadīties,
ka vienlaicīgi tiek strādāts pie vienas un tās paša koda gabala. 
Kā viens nokompilē pakotni, funkciju, procedūru, tā otra izmaiņas pazūd, 
ja tā notiek tad no `plsql_archive` tabulas var dabūt iepriekšējās koda versijas.

Koda darbības princips:

Tiek izveidots shēmas trigeris `t_plsql_backup`. Labi, ka iekš oracle tādi trigeri ir iespējami.
Kā tiek pārkompilēts kāds shēmas objekts tā trigeris izpilda `plsql_backup.backup` procedūru,
kas saglabā izmainītā objekta kodu un tad atļauj jaunam izmaiņam uzstādīties serverī.

installation
==============
skripta uzstādīšanas secība:
1) `table.sql`
2) `package.sql`
3) `trigger.sql`
