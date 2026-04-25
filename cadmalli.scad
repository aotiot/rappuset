// --- PARAMETRIT ---
eps = 0.05; 

tasanne_leveys = 900; 
tasanne_syvyys = 1200; 
kokonaiskorkeus = 1200; 

askelmien_maara = 6; 
nousuja_yhteensa = 7; 
askelma_nousu = kokonaiskorkeus / nousuja_yhteensa; // ~171.4 mm
askelma_etenema = 290; 

portaan_leveys = 800; 
lauta_paksuus = 28; 
runko_korkeus = 148; 
reisilankku_paksuus = 48; 
reisilankku_leveys = 198; 

kaide_korkeus = 950; 
kaide_paksuus = 50; // Käsijohteen paksuus/leveys
rima_leveys = 45;
rima_paksuus = 28;
rima_jako = 140; // Rimojen väli keskeltä keskelle (jättää n. 95mm raon)

tolppa_koko = 98; 

// --- MALLINNUS ---

// 1. TUKITOLPAT
module tolppa() {
    cube([tolppa_koko, tolppa_koko, kokonaiskorkeus - lauta_paksuus - runko_korkeus]);
}
translate([0, tasanne_syvyys - tolppa_koko, 0]) tolppa();
translate([tasanne_leveys - tolppa_koko, tasanne_syvyys - tolppa_koko, 0]) tolppa();
translate([0, 0, 0]) tolppa();
translate([tasanne_leveys - tolppa_koko, 0, 0]) tolppa();

// 2. RISTITUKI
translate([0, 0, kokonaiskorkeus - runko_korkeus - lauta_paksuus - 50]) {
    diag_pituus = sqrt(pow(tasanne_leveys, 2) + pow(tasanne_syvyys, 2));
    angle = atan(tasanne_syvyys / tasanne_leveys);
    rotate([0, 0, angle]) cube([diag_pituus, 28, 45]);
    translate([tasanne_leveys, 0, 0]) rotate([0, 0, 180 - angle]) cube([diag_pituus, 28, 45]);
}

// 3. TERASSIN KANSI JA RUNKO
translate([0, 0, kokonaiskorkeus - lauta_paksuus])
    cube([tasanne_leveys, tasanne_syvyys, lauta_paksuus]);

translate([0, 0, kokonaiskorkeus - runko_korkeus - lauta_paksuus])
    difference() {
        cube([tasanne_leveys, tasanne_syvyys, runko_korkeus]);
        translate([reisilankku_paksuus, reisilankku_paksuus, -eps])
            cube([tasanne_leveys - (2 * reisilankku_paksuus), tasanne_syvyys - (2 * reisilankku_paksuus), runko_korkeus + 2 * eps]);
    }

// 4. SUORAT REISILANKUT
module suora_reisilankku() {
    run = askelmien_maara * askelma_etenema;
    rise = kokonaiskorkeus - askelma_nousu;
    pituus = sqrt(pow(run, 2) + pow(rise, 2)) + 400;
    angle = -atan(rise / run);
    
    rotate([angle, 0, 0])
        translate([0, -200, -reisilankku_leveys + 30])
            cube([reisilankku_paksuus, pituus, reisilankku_leveys]);
}

translate([(tasanne_leveys - portaan_leveys) / 2, tasanne_syvyys, kokonaiskorkeus])
    suora_reisilankku();

translate([(tasanne_leveys - portaan_leveys) / 2 + portaan_leveys - reisilankku_paksuus, tasanne_syvyys, kokonaiskorkeus])
    suora_reisilankku();

// 5. ASKELMAT (Vain tasot)
for(i = [0 : askelmien_maara - 1]) {
    z_pinta = kokonaiskorkeus - ((i + 1) * askelma_nousu);
    y_pos = tasanne_syvyys + (i * askelma_etenema);
    
    translate([(tasanne_leveys - portaan_leveys) / 2 + reisilankku_paksuus, y_pos, z_pinta - lauta_paksuus])
        cube([portaan_leveys - 2 * reisilankku_paksuus, askelma_etenema, lauta_paksuus]);
}

// 6. VIIMEISTELTY KAIDE

// A. Tasanteen sivukaide (Vasen sivu)
translate([0, 0, kokonaiskorkeus]) {
    // Käsijohde (Yhdistyy päätyyn)
    translate([0, 0, kaide_korkeus])
        cube([kaide_paksuus, tasanne_syvyys, kaide_paksuus]);
    
    // Pystyrimat tasaisella jaolla
    for(y = [rima_jako/2 : rima_jako : tasanne_syvyys - rima_leveys])
        translate([(kaide_paksuus-rima_paksuus)/2, y, 0]) 
            cube([rima_paksuus, rima_leveys, kaide_korkeus]);
}

// B. Tasanteen päätykaide (Takareuna)
translate([0, 0, kokonaiskorkeus]) {
    // Käsijohde
    translate([0, 0, kaide_korkeus])
        cube([tasanne_leveys, kaide_paksuus, kaide_paksuus]);
        
    // Pystyrimat
    for(x = [kaide_paksuus + rima_jako : rima_jako : tasanne_leveys - rima_leveys])
        translate([x, (kaide_paksuus-rima_paksuus)/2, 0]) 
            cube([rima_leveys, rima_paksuus, kaide_korkeus]);
}

// C. Porraskaide (Vasen reuna)
translate([(tasanne_leveys - portaan_leveys) / 2, tasanne_syvyys, 0]) {
    run_v = askelmien_maara * askelma_etenema;
    rise_v = kokonaiskorkeus - askelma_nousu;
    pituus_v = sqrt(pow(run_v, 2) + pow(rise_v, 2)) + 150;
    kulma_v = -atan(rise_v / run_v);
    
    // Käsijohde, joka alkaa tarkalleen tasanteen kulmasta
    translate([0, 0, kokonaiskorkeus + kaide_korkeus]) 
        rotate([kulma_v, 0, 0]) 
            cube([kaide_paksuus, pituus_v, kaide_paksuus]);
        
    // Pystyrimat jokaiselle askelmalle
    for(i = [0 : askelmien_maara - 1]) {
        z_base = kokonaiskorkeus - ((i + 1) * askelma_nousu);
        y_loc = i * askelma_etenema + 150;
        
        // Rima kiinnittyy askelmaan
        translate([(kaide_paksuus-rima_paksuus)/2, y_loc, z_base]) 
            cube([rima_paksuus, rima_leveys, kaide_korkeus]);
    }
}
