// 0   齿轮箱 立体
// 1   齿轮箱  CAD
// 2   主机

     //摄像头机架    

SHOW =2;

$fn=96;
// Spiel zwischen Zahnflanken 齿间隙
spiel = 0.01;
// Höhe des Zahnkopfes über dem Teilkreis 放缩比例
modul =1   ; //0.68;
// Anzahl der Radzähne des Sonnenrads 中心齿轮齿数
zahnzahl_sonne = 14;
// Anzahl der Radzähne der Planetenräder 边缘齿轮齿数
zahnzahl_planet =56;
// Zahnbreite 总厚度
breite = 1;


// Breite des Randes ab Fußkreis 边缘厚度
randbreite = 5 + 4;
// Durchmesser der Mittelbohrung 中心齿轮中心孔直径
bohrung1 = 5-0.1 ;

// Durchmesser der Mittelbohrung 边缘齿轮中心孔直径
bohrung2 =0;//  7.6+0.1;


// Eingriffswinkel, Standardwert = 20° gemäß DIN 867v 齿角度
eingriffswinkel = 26;
// Schrägungswinkel zur Rotationsachse; 0° = Geradverzahnung 齿斜度
schraegungswinkel = 0;
// Zusammen gebaut oder zum Drucken getrennt  显示 位置
zusammen_gebaut = 0;
// Löcher zur Material-/Gewichtsersparnis bzw. Oberflächenvergößerung erzeugen, wenn Geometrie erlaubt
optimiert1 = false; // 不优化 边齿

optimiert2 = false; // 不优化 中心齿

ADDbreite = 0;

// Bibliothek für Planetenräder für Thingiverse Customizer

//Enthält die Module
//stirnrad(modul, zahnzahl, breite, bohrung, eingriffswinkel = 20, schraegungswinkel = 0, optimiert = true);
//pfeilrad(modul, zahnzahl, breite, bohrung, eingriffswinkel = 20, schraegungswinkel=0, optimiert=true);
//hohlrad(modul, zahnzahl, breite, randbreite, eingriffswinkel = 20, schraegungswinkel = 0);
//pfeilhohlrad(modul, zahnzahl, breite, randbreite, eingriffswinkel = 20, schraegungswinkel = 0);
//planetengetriebe(modul, zahnzahl_sonne, zahnzahl_planet, breite, randbreite, bohrung, eingriffswinkel=20, schraegungswinkel=0, zusammen_gebaut=true, optimiert=true);
/*
  Autor:    Dr Jörg Janssen
  Stand:    6. Januar 2017
  Version:  2.0
  Lizenz:   Creative Commons - Attribution, Non Commercial, Share Alike

  Erlaubte Module nach DIN 780:
  0.05 0.06 0.08 0.10 0.12 0.16
  0.20 0.25 0.3  0.4  0.5  0.6
  0.7  0.8  0.9  1    1.25 1.5
  2    2.5  3    4    5    6
  8    10   12   16   20   25
  32   40   50   60

*/


/* [Hidden] */
pi = 3.1415926;
rad = 57.29578;
//$fn = 96;
RRR = 0;
/*  Wandelt Radian in Grad um */
function grad(eingriffswinkel) =  eingriffswinkel * rad;


/*  Wandelt Grad in Radian um */
function radian(eingriffswinkel) = eingriffswinkel / rad;


/*  Wandelt 2D-Polarkoordinaten in kartesische um
    Format: radius, phi; phi = Winkel zur x-Achse auf xy-Ebene */
function pol_zu_kart(polvect) = [
                                  polvect[0] * cos(polvect[1]),
                                  polvect[0] * sin(polvect[1])
                                ];

/*  Wandelt Kugelkoordinaten in kartesische um
    Format: radius, theta, phi; theta = Winkel zu z-Achse, phi = Winkel zur x-Achse auf xy-Ebene */
function kugel_zu_kart(vect) = [
                                 vect[0] * sin(vect[1]) * cos(vect[2]),
                                 vect[0] * sin(vect[1]) * sin(vect[2]),
                                 vect[0] * cos(vect[1])
                               ];

/*  Kreisevolventen-Funktion:
    Gibt die Polarkoordinaten einer Kreisevolvente aus
    r = Radius des Grundkreises
    rho = Abrollwinkel in Grad */
function ev(r, rho) = [
                        r / cos(rho),
                        grad(tan(rho) - radian(rho))
                      ];


/*  prüft, ob eine Zahl gerade ist
  = 1, wenn ja
  = 0, wenn die Zahl nicht gerade ist */
function istgerade(zahl) =
  (zahl == floor(zahl / 2) * 2) ? 1 : 0;


/*  größter gemeinsamer Teiler
  nach Euklidischem Algorithmus.
  Sortierung: a muss größer als b sein */
function ggt(a, b) =
  a % b == 0 ? b : ggt(b, a % b);

/*  Stirnrad
    modul = Höhe des Zahnkopfes über dem Teilkreis
    zahnzahl = Anzahl der Radzähne
    breite = Zahnbreite
    bohrung = Durchmesser der Mittelbohrung
    eingriffswinkel = Eingriffswinkel, Standardwert = 20° gemäß DIN 867. Sollte nicht größer als 45° sein.
    schraegungswinkel = Schrägungswinkel zur Rotationsachse; 0° = Geradverzahnung
  optimiert = Löcher zur Material-/Gewichtsersparnis bzw. Oberflächenvergößerung erzeugen, wenn Geometrie erlaubt (= 1, wenn wahr) */
module stirnrad(modul, zahnzahl, breite, bohrung1, eingriffswinkel = 20, schraegungswinkel = 0, optimiert1 = false) {

  // Dimensions-Berechnungen
  d = modul * zahnzahl;                     // Teilkreisdurchmesser
  r = d / 2;                            // Teilkreisradius
  alpha_stirn = atan(tan(eingriffswinkel) / cos(schraegungswinkel)); // Schrägungswinkel im Stirnschnitt
  db = d * cos(alpha_stirn);                    // Grundkreisdurchmesser
  rb = db / 2;                          // Grundkreisradius
  da = (modul < 1) ? d + modul * 2.2 : d + modul * 2;     // Kopfkreisdurchmesser nach DIN 58400 bzw. DIN 867
  ra = da / 2;                          // Kopfkreisradius
  c =  (zahnzahl < 3) ? 0 : modul / 6;            // Kopfspiel
  df = d - 2 * (modul + c);                   // Fußkreisdurchmesser
  rf = df / 2;                          // Fußkreisradius
  rho_ra = acos(rb / ra);                   // maximaler Abrollwinkel;
  // Evolvente beginnt auf Grundkreis und endet an Kopfkreis
  rho_r = acos(rb / r);                     // Abrollwinkel am Teilkreis;
  // Evolvente beginnt auf Grundkreis und endet an Kopfkreis
  phi_r = grad(tan(rho_r) - radian(rho_r));           // Winkel zum Punkt der Evolvente auf Teilkreis
  gamma = rad * breite / (r * tan(90 - schraegungswinkel)); // Torsionswinkel für Extrusion
  schritt = rho_ra / 16;                    // Evolvente wird in 16 Stücke geteilt
  tau = 360 / zahnzahl;                     // Teilungswinkel

  r_loch = (2 * rf - bohrung1) / 8;             // Radius der Löcher für Material-/Gewichtsersparnis
  rm = bohrung1 / 2 + 2 * r_loch;             // Abstand der Achsen der Löcher von der Hauptachse
  z_loch = floor(2 * pi * rm / (3 * r_loch));       // Anzahl der Löcher für Material-/Gewichtsersparnis

  optimiert1 = (optimiert1 && r >= breite * 1.5 && d > 2 * bohrung1); // ist Optimierung sinnvoll?

  // Zeichnung
  union() {
    rotate([0, 0, -phi_r - 90 * (1 - spiel) / zahnzahl]) { // Zahn auf x-Achse zentrieren;
      // macht Ausrichtung mit anderen Rädern einfacher

      linear_extrude(height = breite, twist = gamma) {
        difference() {
          union() {
            zahnbreite = (180 * (1 - spiel)) / zahnzahl + 2 * phi_r;
            circle(rf);                   // Fußkreis
            for (rot = [0:tau:360]) {
              rotate (rot) {              // "Zahnzahl-mal" kopieren und drehen
                polygon(concat(             // Zahn
                          [[0, 0]],             // Zahnsegment beginnt und endet im Ursprung
                          [for (rho = [0:schritt:rho_ra])   // von null Grad (Grundkreis)
                           // bis maximalen Evolventenwinkel (Kopfkreis)
                           pol_zu_kart(ev(rb, rho))],  // Erste Evolventen-Flanke

                          [pol_zu_kart(ev(rb, rho_ra))],  // Punkt der Evolvente auf Kopfkreis

                          [for (rho = [rho_ra: -schritt:0]) // von maximalen Evolventenwinkel (Kopfkreis)
                           // bis null Grad (Grundkreis)
                           pol_zu_kart([ev(rb, rho)[0], zahnbreite - ev(rb, rho)[1]])]
                          // Zweite Evolventen-Flanke
                          // (180*(1-spiel)) statt 180 Grad,
                          // um Spiel an den Flanken zu erlauben
                        )
                       );
              }
            }
          }
          circle(r = rm + r_loch * 1.49);          // "Bohrung"
        }
      }
    }
    // mit Materialersparnis
    if (optimiert1) {


      linear_extrude(height = breite) {
        difference() {
          circle(r = (bohrung1 + r_loch) / 2);
          circle(r = bohrung1 / 2);           // Bohrung
        }
      }
      linear_extrude(height = (breite - r_loch / 2 < breite * 2 / 3) ? breite * 2 / 3 : breite - r_loch / 2) {
        difference() {
          circle(r = rm + r_loch * 1.51);
          union() {
            circle(r = (bohrung1 + r_loch) / 2);
            for (i = [0:1:z_loch]) {
              translate(kugel_zu_kart([rm, 90, i * 360 / z_loch]))
              circle(r = r_loch);
            }
          }
        }
      }

    }
    // ohne Materialersparnis
    else {
      linear_extrude(height = breite) {
        difference() {
          circle(r = rm + r_loch * 1.51);
          circle(r = bohrung1 / 2);
        }
      }
    }
  }
}

/*  Pfeilrad; verwendet das Modul "stirnrad"
    modul = Höhe des Zahnkopfes über dem Teilkreis
    zahnzahl = Anzahl der Radzähne
    breite = Zahnbreite
    bohrung = Durchmesser der Mittelbohrung
    eingriffswinkel = Eingriffswinkel, Standardwert = 20° gemäß DIN 867. Sollte nicht größer als 45° sein.
    schraegungswinkel = Schrägungswinkel zur Rotationsachse, Standardwert = 0° (Geradverzahnung)
  optimiert = Löcher zur Material-/Gewichtsersparnis */
module pfeilrad(modul, zahnzahl, breite, bohrung2, eingriffswinkel = 20, schraegungswinkel = 0, optimiert2 = false) {

  breite = breite / 2;
  d = modul * zahnzahl;                     // Teilkreisdurchmesser
  r = d / 2;                            // Teilkreisradius
  c =  (zahnzahl < 3) ? 0 : modul / 6;            // Kopfspiel

  df = d - 2 * (modul + c);                   // Fußkreisdurchmesser
  rf = df / 2;                          // Fußkreisradius

  r_loch = (2 * rf - bohrung2) / 8;             // Radius der Löcher für Material-/Gewichtsersparnis
  rm = bohrung2 / 2 + 2 * r_loch;             // Abstand der Achsen der Löcher von der Hauptachse
  z_loch = floor(2 * pi * rm / (3 * r_loch));       // Anzahl der Löcher für Material-/Gewichtsersparnis

  optimiert2 = (optimiert2 && r >= breite * 3 && d > 2 * bohrung2); // ist Optimierung sinnvoll?

  translate([0, 0, breite]) {
    union() {
      stirnrad(modul, zahnzahl, breite, 2 * (rm + r_loch * 1.49), eingriffswinkel, schraegungswinkel, false); // untere Hälfte
      mirror([0, 0, 1]) {
        stirnrad(modul, zahnzahl, breite, 2 * (rm + r_loch * 1.49), eingriffswinkel, schraegungswinkel, false); // obere Hälfte
      }
    }
  }
  
  
  // mit Materialersparnis
  if (optimiert2) {
    linear_extrude(height = breite * 2) {
      difference() {
        circle(r = (bohrung2 + r_loch) / 2);
        circle(r = bohrung2 / 2);           // Bohrung
      }
    }
    linear_extrude(height = (2 * breite - r_loch / 2 < 1.33 * breite) ? 1.33 * breite : 2 * breite - r_loch / 2) { //breite*4/3
      difference() {
        circle(r = rm + r_loch * 1.51);
        union() {
          circle(r = (bohrung2 + r_loch) / 2);
          for (i = [0:1:z_loch]) {
            translate(kugel_zu_kart([rm, 90, i * 360 / z_loch]))
            circle(r = r_loch);
          }
        }
      }
    }
  }
  // ohne Materialersparnis
  else {
    linear_extrude(height = breite * 2) {
      difference() {
        circle(r = rm + r_loch * 1.51);
        circle(r = bohrung2 / 2);
      }
    }
  }
}

/*  Hohlrad
    modul = Höhe des Zahnkopfes über dem Teilkreis
    zahnzahl = Anzahl der Radzähne
    breite = Zahnbreite
  randbreite = Breite des Randes ab Fußkreis
    bohrung = Durchmesser der Mittelbohrung
    eingriffswinkel = Eingriffswinkel, Standardwert = 20° gemäß DIN 867. Sollte nicht größer als 45° sein.
    schraegungswinkel = Schrägungswinkel zur Rotationsachse, Standardwert = 0° (Geradverzahnung) */
module hohlrad(modul, zahnzahl, breite, randbreite, eingriffswinkel = 20, schraegungswinkel = 0) {

  // Dimensions-Berechnungen
  ha = (zahnzahl >= 20) ? 0.02 * atan((zahnzahl / 15) / pi) : 0.6; // Verkürzungsfaktor Zahnkopfhöhe
  d = modul * zahnzahl;                     // Teilkreisdurchmesser
  r = d / 2;                            // Teilkreisradius
  alpha_stirn = atan(tan(eingriffswinkel) / cos(schraegungswinkel)); // Schrägungswinkel im Stirnschnitt
  db = d * cos(alpha_stirn);                    // Grundkreisdurchmesser
  rb = db / 2;                          // Grundkreisradius
  c = modul / 6;                          // Kopfspiel
  da = (modul < 1) ? d + (modul + c) * 2.2 : d + (modul + c) * 2; // Kopfkreisdurchmesser
  ra = da / 2;                          // Kopfkreisradius
  df = d - 2 * modul * ha;                    // Fußkreisdurchmesser
  rf = df / 2;                          // Fußkreisradius
  rho_ra = acos(rb / ra);                   // maximaler Evolventenwinkel;
  // Evolvente beginnt auf Grundkreis und endet an Kopfkreis
  rho_r = acos(rb / r);                     // Evolventenwinkel am Teilkreis;
  // Evolvente beginnt auf Grundkreis und endet an Kopfkreis
  phi_r = grad(tan(rho_r) - radian(rho_r));           // Winkel zum Punkt der Evolvente auf Teilkreis
  gamma = rad * breite / (r * tan(90 - schraegungswinkel)); // Torsionswinkel für Extrusion
  schritt = rho_ra / 16;                    // Evolvente wird in 16 Stücke geteilt
  tau = 360 / zahnzahl;                     // Teilungswinkel

  // Zeichnung
  rotate([0, 0, -phi_r - 90 * (1 + spiel) / zahnzahl])  // Zahn auf x-Achse zentrieren;
  // macht Ausrichtung mit anderen Rädern einfacher
  linear_extrude(height = breite, twist = gamma) {
    difference() {
        
        union()
        {
           circle(r = ra + randbreite);              // Außenkreis
           //translate([0, 0, 0]) cube([200, 14, 4], center = true);
        }
        
        
      RRR =  ra + randbreite;

      union() {
          
          
        //   translate([0, 0, 0]) cube([200, 14, 4], center = true);
          
        zahnbreite = (180 * (1 + spiel)) / zahnzahl + 2 * phi_r;
        circle(rf);                     // Fußkreis
        for (rot = [0:tau:360]) {
          rotate (rot) {                  // "Zahnzahl-mal" kopieren und drehen
            polygon( concat(
                       [[0, 0]],
                       [for (rho = [0:schritt:rho_ra])     // von null Grad (Grundkreis)
                        // bis maximaler Evolventenwinkel (Kopfkreis)
                        pol_zu_kart(ev(rb, rho))],
                       [pol_zu_kart(ev(rb, rho_ra))],
                       [for (rho = [rho_ra: -schritt:0])   // von maximaler Evolventenwinkel (Kopfkreis)
                        // bis null Grad (Grundkreis)
                        pol_zu_kart([ev(rb, rho)[0], zahnbreite - ev(rb, rho)[1]])]
                       // (180*(1+spiel)) statt 180,
                       // um Spiel an den Flanken zu erlauben
                     )
                   );
          }
        }
      }
    }
  }

  echo("Außendurchmesser Hohlrad = ", 2 * (ra + randbreite));

}

/*  Pfeil-Hohlrad; verwendet das Modul "hohlrad"
    modul = Höhe des Zahnkopfes über dem Teilkegel
    zahnzahl = Anzahl der Radzähne
    breite = Zahnbreite
    bohrung = Durchmesser der Mittelbohrung
    eingriffswinkel = Eingriffswinkel, Standardwert = 20° gemäß DIN 867. Sollte nicht größer als 45° sein.
    schraegungswinkel = Schrägungswinkel zur Rotationsachse, Standardwert = 0° (Geradverzahnung) */
module pfeilhohlrad(modul, zahnzahl, breite, randbreite, eingriffswinkel = 20, schraegungswinkel = 0) {

  breite = breite / 2;
  translate([0, 0, breite])
  union() {
    hohlrad(modul, zahnzahl, breite, randbreite, eingriffswinkel, schraegungswinkel);   // untere Hälfte
    mirror([0, 0, 1])
    hohlrad(modul, zahnzahl, breite, randbreite, eingriffswinkel, schraegungswinkel); // obere Hälfte
  
        
  
      
      }

  
}

/*  Planetengetriebe; verwendet die Module "pfeilrad" und "pfeilhohlrad"
    modul = Höhe des Zahnkopfes über dem Teilkegel
    zahnzahl_sonne = Anzahl der Zähne des Sonnenrads
    zahnzahl_planet = Anzahl der Zähne eines Planetenrads
    breite = Zahnbreite
  randbreite = Breite des Randes ab Fußkreis
    bohrung = Durchmesser der Mittelbohrung
    eingriffswinkel = Eingriffswinkel, Standardwert = 20° gemäß DIN 867. Sollte nicht größer als 45° sein.
    schraegungswinkel = Schrägungswinkel zur Rotationsachse, Standardwert = 0° (Geradverzahnung)
  zusammen_gebaut =
  optimiert = Löcher zur Material-/Gewichtsersparnis bzw. Oberflächenvergößerung erzeugen, wenn Geometrie erlaubt
  zusammen_gebaut = Komponenten zusammengebaut für Konstruktion oder auseinander zum 3D-Druck */
module planetengetriebe(modul, zahnzahl_sonne, zahnzahl_planet, breite, randbreite, bohrung1, bohrung2, eingriffswinkel = 20, schraegungswinkel = 0, zusammen_gebaut = true, optimiert1 = true, optimiert2 = true,SEL=0,X4C30 ) {

  // Dimensions-Berechnungen
  d_sonne = modul * zahnzahl_sonne;                 // Teilkreisdurchmesser Sonne
  d_planet = modul * zahnzahl_planet;               // Teilkreisdurchmesser Planeten
  achsabstand = modul * (zahnzahl_sonne +  zahnzahl_planet) / 2; // Abstand von Sonnenrad-/Hohlradachse und Planetenachse
  zahnzahl_hohlrad = zahnzahl_sonne + 2 * zahnzahl_planet;      // Anzahl der Zähne des Hohlrades

  drehen = istgerade(zahnzahl_planet);                // Muss das Sonnenrad gedreht werden?


  n_start = (zahnzahl_planet > zahnzahl_sonne) ? ggt(zahnzahl_planet, zahnzahl_sonne) : ggt(zahnzahl_sonne, zahnzahl_planet);
  // Anzahl Planetenräder: höchstens größter gemeinsamer
  // Teiler von Anzahl der Zähne des Sonnen- und
  // Planetenrads

  n_max = floor(180 / asin(modul * (zahnzahl_planet) / (modul * (zahnzahl_sonne +  zahnzahl_planet))));
  // Anzahl Planetenräder: höchstens so viele, wie ohne
  // Überlappung möglich

  list = [ for (n = [n_start : -1 : 1]) if ((n < n_max) && (ggt(zahnzahl_hohlrad, n) != 1)) n];

  //随动 齿轮个数
  n_planeten = 3; // list[0];                       // Ermittele Anzahl Planetenräder

  if(SEL==0 || SEL==1)
  {
  // Zeichnung
    rotate([0, 0, 180 / zahnzahl_sonne * drehen]) {
    pfeilrad (modul, zahnzahl_sonne, breite*4, bohrung1, eingriffswinkel, -schraegungswinkel, optimiert2);   // Sonnenrad
    } 
  }

 if(SEL==0 || SEL==2)
  {
    //
   translate([90, 0, 3])  rotate([0, 0, 180 / zahnzahl_sonne * drehen]) {
    pfeilrad (modul, zahnzahl_sonne, breite*4, 7.9, eingriffswinkel, -schraegungswinkel, optimiert2);   // Sonnenrad
     } 
 }

 if(SEL==0 || SEL==3)
  {
  if (zusammen_gebaut) {
    achsabstand = modul * (zahnzahl_sonne + zahnzahl_planet) / 2; // Abstand von Sonnenrad-/Hohlradachse
    for (rot = [0:360 / n_planeten:360 / n_planeten * (n_planeten - 1)]) {
      translate(kugel_zu_kart([achsabstand, 90, rot]))
      //                       比例
          difference() {
      color("green")pfeilrad (modul, zahnzahl_planet, breite, bohrung2, eingriffswinkel * 0.9, schraegungswinkel); // Planetenräder
        
               //     模式 中心齿轮 缩放
           pfeilrad (modul*0.92, zahnzahl_sonne , breite*6, bohrung1, eingriffswinkel, -schraegungswinkel, optimiert2);   
          
              
              
              }
    }
 
  }
  else {
    planetenabstand = zahnzahl_hohlrad * modul / 2 + randbreite + d_planet; // Abstand Planeten untereinander
    for (i = [-(n_planeten - 1):2:(n_planeten - 1)]) 
        {
        /////////    
      translate([planetenabstand, d_planet * i, 0])
      difference() {
         color("green")pfeilrad (modul, zahnzahl_planet, breite, bohrung2, eingriffswinkel, schraegungswinkel);  // Planetenräder
          
        //   ZHUZI(5);    模式 中心齿轮 缩放
            pfeilrad (modul*0.92, zahnzahl_sonne , breite*6, bohrung1, eingriffswinkel, -schraegungswinkel, optimiert2);   
          
          
             }
      }
    }
  
  }

 if(SEL==0 || SEL==4)
  {
 if (zusammen_gebaut) {
 color("red")  translate([0, 0, 2])
    {
        pfeilhohlrad (modul, zahnzahl_hohlrad-X4C30, breite + ADDbreite, randbreite, eingriffswinkel, schraegungswinkel); // Hohlrad
        
      //
       HUANX2(  );
    }

 }else
 {
 color("red")  translate([-150, 0, 2]) 
     {
         pfeilhohlrad (modul, zahnzahl_hohlrad-X4C30, breite + ADDbreite, randbreite, eingriffswinkel, schraegungswinkel); // Hohlrad


         HUANX2(  );
     }
 }
  
 }
 // 三角
if(SEL==0 || SEL==5)
  {
   achsabstand = modul * (zahnzahl_sonne + zahnzahl_planet) / 2; // Abstand von Sonnenrad-/Hohlradachse
    for (rot = [0:360 / n_planeten:360 / n_planeten * (n_planeten - 1)]) {
      translate(kugel_zu_kart([achsabstand, 90, rot]))
      //                       比例
        cylinder (h = 20,r =4.7 / 2, center = true);
    }
  }
}

//齿轮环  长方形
module HUANX(HRR=108, RX= 100 )
{
 

 difference() {

   union()
     {
    cube([140,62, 1.5], center = true);
         cylinder (h = 1.5, r = HRR/2, center = true);
     }
          cylinder (h = 15, r = RX/2, center = true); //31/2 +2

rotate([0, 0, 90])  kongWai(modul, zahnzahl_hohlrad, breite, randbreite);
// kongNei(modul, zahnzahl_hohlrad, breite, randbreite);
 }
}


//齿轮环  长方形
module HUANX2( RX= 100 )
{
 

 difference() {

   union()
     {
    cube([140,62, 1.5], center = true);
        cylinder (h = 1.5, r=108/2, center = true);
     }
          cylinder (h = 15, r = RX/2, center = true); //31/2 +2

rotate([0, 0, 90])   kongWai(modul, zahnzahl_hohlrad, breite, randbreite);
 kongNei(modul, zahnzahl_hohlrad, breite, randbreite);
 }
}


// 轮环   
module HUAN9575(  )
{
 

 difference() {

   union()
     {
   
         cylinder (h = 10, r = 95/2, center = true);
     }
          cylinder (h = 12, r = 75/2, center = true); //31/2 +2


 }
}



//             0 1 2 3 4   ,X4C30 外圈齿轮 直径调节
module Z42BYG(SEL=0, X4C30 )
{


  rotate(a = [0, 0, 90])
  {
    planetengetriebe(modul, zahnzahl_sonne, zahnzahl_planet, breite, randbreite, bohrung1, bohrung2, eingriffswinkel, schraegungswinkel, zusammen_gebaut, optimiert1, optimiert2,SEL ,X4C30 );






    color("blue")  translate([2.2, 0, 0.5]) cube([1, 4, 1], center = true);

  }


}



module Z4(modul, zahnzahl, breite, randbreite)
{
  JL = 31 / 2;
  hh = 10;

  d = modul * zahnzahl;
  r = d / 2;
  c = modul / 6;                          // Kopfspiel
  da = (modul < 1) ? d + (modul + c) * 2.2 : d + (modul + c) * 2; // Kopfkreisdurchmesser
  ra = da / 2;
  RRRX =  ra + randbreite;

  difference() {
        
      union()
      {
    cylinder (h = 1, r = RRRX, center = true); //31/2 +2

    cube([62, 140, 1], center = true);
      }
    translate([0, 0, 0]) rotate([0, 0, 0]) cylinder (h = 2, r = 23 / 2 , center = true);
      
     rotate([0,0,45])  
   {   
 translate([ 31/2, 31/2,0]) rotate([0,0,0]) cylinder (h = hh, r=3/2, center = true);
  translate([- 31/2, 31/2,0])rotate([0,0,0]) cylinder (h = hh, r=3/2, center = true);

    translate([ -31 / 2, -31 / 2, 0]) rotate([0, 0, 0]) cylinder (h = hh, r = 3 / 2, center = true);
    translate([ 31 / 2, - 31 / 2, 0])rotate([0, 0, 0]) cylinder (h = hh, r = 3 / 2, center = true);
  }

rotate([0, 0,  0])  kongWai(modul, zahnzahl_hohlrad, breite, randbreite);
 kongNei(modul, zahnzahl_hohlrad, breite, randbreite);
  }

  /*
    translate([0,0,0])difference() {

         cylinder (h = 1, r=RRRX*3/4, center = true);

        translate([0,0,0]) rotate([0,0,0]) cylinder (h = 2, r=32/2 +2, center = true);
       translate([31/2,31/2,0]) rotate([0,0,0]) cylinder (h = 10, r=3/2, center = true);
        translate([-31/2,31/2,0])rotate([0,0,0]) cylinder (h = 10, r=3/2, center = true);

        translate([31/2,-31/2,0]) rotate([0,0,0]) cylinder (h = 10, r=3/2, center = true);
        translate([-31/2,-31/2,0])rotate([0,0,0]) cylinder (h = 10, r=3/2, center = true);

    }
  */


}

module Z4o( RRXXC= 80,KONGX=4.6  )
{
 
   // 7.6+0.1;

  rotate([0, 0,  0]) translate([0, 0, 0])difference()
  {

    cylinder (h = 1, r = RRXXC / 2, center = true);

    
    translate([0,0,0]) Z42BYG(SEL=5, X4C30= X4C30X); //齿轮组


 cylinder (h = 10, r = 8 / 2, center = true);
  }

}

module  SanJiao(XRR=4.5)
{
      X4C30X=42;
      translate([0,0,0]) Z42BYG(SEL=5, X4C30= X4C30X); //齿轮组
    
    /*
    HHHHV =22;
    
    HX1= 39.2;
    HX2 = 67.9;
    HX3=  78.4;
     translate([-HX1/2,HX2/2,0]) rotate([0,0,0])
     {
         cylinder (h = HHHHV, r=XRR/2, center = true);
         //   ZHUZI(3.6);
     }
 translate([HX3/2,0,0])rotate([0,0,0]) 
     {
         cylinder (h = HHHHV, r=XRR/2, center = true);
         //   ZHUZI(3.6);
     }
     

 translate([-HX1/2,-HX2/2,0]) rotate([0,0,0]) 
     {
         cylinder (h = HHHHV, r=XRR/2, center = true);
         //   ZHUZI(3.6);
     }
    */
    
}


module Z4o1(modul, zahnzahl, breite, randbreite)
{
  JL = 12.24;
  hh = 50;

  d = modul * zahnzahl;
  r = d / 2;
  c = modul / 6;                          // Kopfspiel
  da = (modul < 1) ? d + (modul + c) * 2.2 : d + (modul + c) * 2; // Kopfkreisdurchmesser
  ra = da / 2;
  RRRX =  ra + randbreite;

 

  XRR = 3;

  rotate([0, 0, -30]) translate([0, 0, 0])difference()
  {

    cylinder (h = 1, r = RRRX * 8.5 / 10, center = true);

    translate([0, 0, 0]) rotate([0, 0, 0]) cylinder (h = 2, r = 8 / 2, center = true);

 SanJiao(XRR=3);


  }

}


module Z4o2(modul, zahnzahl, breite, randbreite)
{
  JL =90;
  hh = 150;

  d = modul * zahnzahl;
  r = d / 2;
  c = modul / 6;                          // Kopfspiel
  da = (modul < 1) ? d + (modul + c) * 2.2 : d + (modul + c) * 2; // Kopfkreisdurchmesser
  ra = da / 2;
  RRRX =  ra + randbreite;

  difference() {

    cylinder (h = 1, r = 100, center = true);

  //  translate([0, 0, 0]) rotate([0, 0, 0]) cylinder (h = 2, r = RRRX * 8.53 / 10, center = true);
      
       rotate([0, 0, 0])
      {
     translate([ JL, 0, 0]) rotate([0, 0, 0]) cylinder (h = hh, r = 8 / 2, center = true);
     translate([- JL, 0, 0])rotate([0, 0, 0]) cylinder (h = hh, r = 8 / 2, center = true);

     translate([0, JL, 0]) rotate([0, 0, 0]) cylinder (h = hh, r = 8 / 2, center = true);
     translate([0, - JL, 0])rotate([0, 0, 0]) cylinder (h = hh, r = 8 / 2, center = true);
      }
      
             rotate([0, 0, 45])
      {
     translate([ JL, 0, 0]) rotate([0, 0, 0]) cylinder (h = hh, r = 8 / 2, center = true);
     translate([- JL, 0, 0])rotate([0, 0, 0]) cylinder (h = hh, r = 8 / 2, center = true);

     translate([0, JL, 0]) rotate([0, 0, 0]) cylinder (h = hh, r = 8 / 2, center = true);
     translate([0, - JL, 0])rotate([0, 0, 0]) cylinder (h = hh, r = 8 / 2, center = true);
      }



  XRR = 5;

  rotate([0, 0, -30]) translate([0, 0, 0]) 
  {

 //   cylinder (h = 1, r = RRRX * 8.5 / 10, center = true);

    translate([0, 0, 0]) rotate([0, 0, 0]) cylinder (h = 2, r = 8 / 2, center = true);

 //SanJiao(XRR=5);
  translate([0,0,0]) Z42BYG(SEL=5, X4C30= X4C30X); //齿轮组

  }
  
  
    }
  

}

module kongWai()
{

  JL = 67;
  hh = 40;

 

  //  translate([0,0,0]) rotate([0,0,0]) cylinder (h = 2, r=RRRX*8/10, center = true);
  translate([  20,JL, 0]) rotate([0, 0, 0]) cylinder (h = hh, r = 2.9 / 2, center = true);
  translate([ 20,- JL, 0])rotate([0, 0, 0]) cylinder (h = hh, r = 2.9 / 2, center = true);

  translate([-20, JL, 0]) rotate([0, 0, 0]) cylinder (h = hh, r = 2.9 / 2, center = true);
  translate([-20, - JL, 0])rotate([0, 0, 0]) cylinder (h = hh, r = 2.9 / 2, center = true);

//  translate([0, 0, 0]) rotate([0, 0, 0]) cylinder (h = hh, r = 3 / 2, center = true);
    
        translate([  0,JL, 0]) rotate([0, 0, 0]) cylinder (h = hh, r = 2.9 / 2, center = true);
  translate([ 0,- JL, 0])rotate([0, 0, 0]) cylinder (h = hh, r = 2.9 / 2, center = true);


  translate([  28,JL-3, 0]) rotate([0, 0, 0]) cylinder (h = hh, r = 2.9 / 2, center = true);
  translate([ 28,- JL+3, 0])rotate([0, 0, 0]) cylinder (h = hh, r = 2.9 / 2, center = true);


  translate([-28, JL- 3, 0]) rotate([0, 0, 0]) cylinder (h = hh, r = 2.9 / 2, center = true);
  translate([-28, - JL+3, 0])rotate([0, 0, 0]) cylinder (h = hh, r = 2.9 / 2, center = true);
    
}

module kongNei()
{
  JL = 95/2 +1.5;
  hh = 40;

 

  //  translate([0,0,0]) rotate([0,0,0]) cylinder (h = 2, r=RRRX*8/10, center = true);
  translate([ JL, 0, 0]) rotate([0, 0, 0]) cylinder (h = hh, r = 3 / 2, center = true);
  translate([- JL, 0, 0])rotate([0, 0, 0]) cylinder (h = hh, r = 3 / 2, center = true);

  translate([0, JL, 0]) rotate([0, 0, 0]) cylinder (h = hh, r = 3 / 2, center = true);
  translate([0, - JL, 0])rotate([0, 0, 0]) cylinder (h = hh, r = 3 / 2, center = true);

  translate([0, 0, 0]) rotate([0, 0, 0]) cylinder (h = hh, r = 3 / 2, center = true);
    
       for (rot = [0:60:360]) rotate([0, 0, rot]) {
      translate([ JL, 0, 0]) rotate([0, 0, 0]) cylinder (h = hh, r = 3 / 2, center = true);
  translate([- JL, 0, 0])rotate([0, 0, 0]) cylinder (h = hh, r = 3 / 2, center = true);

  translate([0, JL, 0]) rotate([0, 0, 0]) cylinder (h = hh, r = 3 / 2, center = true);
  translate([0, - JL, 0])rotate([0, 0, 0]) cylinder (h = hh, r = 3 / 2, center = true);

  translate([0, 0, 0]) rotate([0, 0, 0]) cylinder (h = hh, r = 3 / 2, center = true);
       }
}

module Z4t(modul, zahnzahl, breite, randbreite,RRLL= 120)
{

  d = modul * zahnzahl;
  r = d / 2;
  c = modul / 6;                          // Kopfspiel
  da = (modul < 1) ? d + (modul + c) * 2.2 : d + (modul + c) * 2; // Kopfkreisdurchmesser
  ra = da / 2;
  RRRX =  ra + randbreite;


  translate([0, 0, 0])difference() {

    cylinder (h = 1, r = RRRX, center = true);

    translate([0, 0, 0]) rotate([0, 0, 0]) cylinder (h = 2, r = RRLL / 2, center = true);


  }
  
   translate([0, 0, 0])difference() {
    cylinder (h = 1, r = 102/2, center = true);
  cylinder (h = 1, r = 8/2, center = true);
   }
}


module Z4t00(modul, zahnzahl, breite, randbreite,RRLL= 120)
{

  d = modul * zahnzahl;
  r = d / 2;
  c = modul / 6;                          // Kopfspiel
  da = (modul < 1) ? d + (modul + c) * 2.2 : d + (modul + c) * 2; // Kopfkreisdurchmesser
  ra = da / 2;
  RRRX =  ra + randbreite;


  translate([0, 0, 0])difference() {

    cylinder (h = 1, r = RRRX, center = true);

    translate([0, 0, 0]) rotate([0, 0, 0]) cylinder (h = 2, r = RRLL / 2, center = true);


  }
  
  
   
 translate([0, 0, 0])difference() {
    cylinder (h = 1, r = 95/2, center = true);

  cylinder (h = 1, r = 8/2, center = true);
 }

}

module Z4tArm(modul, zahnzahl, breite, randbreite)
{

  d = modul * zahnzahl;
  r = d / 2;
  c = modul / 6;                          // Kopfspiel
  da = (modul < 1) ? d + (modul + c) * 2.2 : d + (modul + c) * 2; // Kopfkreisdurchmesser
  ra = da / 2;
  RRRX =  ra + randbreite;


  translate([0, 0, 0])difference() {

    union()
    {


      translate([415+100, 0, 0])  cylinder (h = 3, r = 50 / 2, center = true);

      translate([90, 0, 0])  cylinder (h = 2, r = 50 / 2, center = true);

      translate([255+50, 0, 0]) cube([340+100, 46, 1], center = true);



    }


 

  translate([90+60,0,0]) 
   {
       cylinder (h = 110, r=19.2/2, center = true);
  BOX36( ) ;

   }
   
 translate([415+100,0,0])
  {
      cylinder (h = 12, r=8.8/2, center = true);
      BOX36( ) ;
  }


    translate([200+75+50, 0, 0]) cube([180+100, 19.2, 4], center = true);
  }


  translate([70, -125, 0])difference() {

    union()
    {

//齿轮环  长方形
     translate([-10,-0,0])rotate([0,0,0]) HUANX( HRR=118,  RX= 88 );

    //  cylinder (h = 1, r = RRRX, center = true);

      translate([25, 50, 0]) cube([50, 120, 1], center = true);

    }

     translate([-10, 0, 0]) rotate([0, 0, 0]) cylinder (h = 2, r = 88/2, center = true);



  //   translate([320, 0, 0])  cylinder (h = 12, r = 118.8 / 2, center = true);
/*
   translate([25, 96, 0]) 
    {
  translate([8,  2, 0])  cylinder (h = 312, r = 3 / 2, center = true);
  translate([-8, 2, 0])  cylinder (h = 312, r = 3 / 2, center = true);
  translate([8, -8, 0])  cylinder (h = 312, r = 3 / 2, center = true);
  translate([-8, -8, 0])  cylinder (h = 312, r = 3 / 2, center = true);
    }
*/

  }


}


module Z4tArm24(modul, zahnzahl, breite, randbreite)
{

  d = modul * zahnzahl;
  r = d / 2;
  c = modul / 6;                          // Kopfspiel
  da = (modul < 1) ? d + (modul + c) * 2.2 : d + (modul + c) * 2; // Kopfkreisdurchmesser
  ra = da / 2;
  RRRX =  ra + randbreite;


  translate([0, 0, 0])difference() {

    union()
    {


      translate([415+4, 0, 0])  cylinder (h = 3, r =22 / 2, center = true);

      translate([90, 0, 0])  cylinder (h = 2, r = 22 / 2, center = true);

      translate([255, 0, 0]) cube([340-3, 20, 1], center = true);



    }




  translate([90,0,0])  cylinder (h = 110, r=8/2, center = true);

 translate([415,0,0])  cylinder (h = 12, r=8/2, center = true);


 //   translate([200, 0, 0]) cube([170, 19.2, 4], center = true);
  }


 


}


module Z4tArm25()
{
 
  translate([0, 0, 0])difference() {

    union()
    {


       translate([80, 0, 0])  cylinder (h = 3, r =22 / 2, center = true);

     translate([-80, 0, 0])  cylinder (h = 2, r = 22 / 2, center = true);

      translate([0, 0, 0]) cube([170, 19, 1], center = true);



    }


  translate([0,0,0])  cylinder (h = 110, r=8/2, center = true);

  translate([80,0,0])  cylinder (h = 110, r=8/2, center = true);

 translate([-80,0,0])  cylinder (h = 12, r=8/2, center = true);


 //   translate([200, 0, 0]) cube([170, 19.2, 4], center = true);
  }


 


}


module Z4tArmBi2(modul, zahnzahl, breite, randbreite)
{

  d = modul * zahnzahl;
  r = d / 2;
  c = modul / 6;                          // Kopfspiel
  da = (modul < 1) ? d + (modul + c) * 2.2 : d + (modul + c) * 2; // Kopfkreisdurchmesser
  ra = da / 2;
  RRRX =  ra + randbreite;


  translate([0, 0, 0])difference() {

    union()
    {


      translate([420+100, 0, 0])  cylinder (h = 3, r = 50 / 2, center = true);

      translate([85, 0, 0])  cylinder (h = 2, r = 50 / 2, center = true);

      translate([255+50, 0, 0]) cube([340+100, 46, 1], center = true);



    }




  translate([90,0,0]) 
   {
       cylinder (h = 110, r=8.8/2, center = true);
       BOX36();
   }
 translate([420-1.55+100,0,0])
 {
     cylinder (h = 102, r=8.8/2, center = true);
  BOX36();
 }

 translate([300+8+100,0,0]) 
{
    cylinder (h = 102, r=8.8/2, center = true);
  BOX36();
}


    translate([200+50, 0, 0]) cube([170+80, 19.2, 4], center = true);


/*
  translate([90,0,0]){
    cylinder (h = 2, r = 8 / 2, center = true);
    translate([31 / 2, 31 / 2, 0]) cylinder (h = 2, r = 3.2 / 2, center = true);
    translate([-31 / 2, 31 / 2, 0]) cylinder (h = 2, r = 3.2 / 2, center = true);
    translate([31 / 2, -31 / 2, 0]) cylinder (h = 2, r = 3.2 / 2, center = true);
    translate([-31 / 2, -31 / 2, 0]) cylinder (h = 2, r = 3.2 / 2, center = true);

  }*/

}





}



module Z4tArm2(modul, zahnzahl, breite, randbreite)
{

  d = modul * zahnzahl;
  r = d / 2;
  c = modul / 6;                          // Kopfspiel
  da = (modul < 1) ? d + (modul + c) * 2.2 : d + (modul + c) * 2; // Kopfkreisdurchmesser
  ra = da / 2;
  RRRX =  ra + randbreite;


  translate([0, 0, 0])difference() {

    union()
    {
          translate([151.7, -13.1 , 0])rotate([0, 0, 45])BOX4(LL=80 );
        translate([53, -156, 0]) rotate([0, 0, 180])  BOX10( );
        
        //齿轮环  长方形
    translate([-0,-0,0])rotate([0,0,0]) HUANX( HRR=118, RX= 88 );
        
   //   cylinder (h = 1, r = RRRX, center = true);


      translate([50+10, -45-15-10, 0]) cube([134+10, 100+14 -44, 1], center = true);

   //  translate([120,  -10, 0]) rotate([0, 0, 35])cube([50+14, 16, 1], center = true);
        
        
     
        
        
    }

    translate([0, 0, 0]) rotate([0, 0, 0]) cylinder (h = 2, r =88/2, center = true);

    HHXX = -10;

    translate([80+40, -45, 0])  cylinder (h = 12, r = 8 / 2, center = true);

  //  translate([123, 5, 0])  cylinder (h = 62, r = 19.2 / 2, center = true);


 translate([135+6,  5,0])  cylinder (h = 12, r=5.2/2, center = true);
/*

 translate([110,-75+HHXX,0])  cylinder (h = 12, r=5.2/2, center = true);
 translate([70,-75+HHXX,0])  cylinder (h = 12, r=5.2/2, center = true);
 translate([30,-75+HHXX,0])  cylinder (h = 12, r=5.2/2, center = true);
 translate([ -10,-75+HHXX,0])  cylinder (h = 12, r=5.2/2, center = true);


 translate([110,-65+HHXX,0])  cylinder (h = 12, r=5.2/2, center = true);
 translate([70,-65+HHXX,0])  cylinder (h = 12, r=5.2/2, center = true);
 translate([30,-65+HHXX,0])  cylinder (h = 12, r=5.2/2, center = true);
 translate([ -10,-65+HHXX,0])  cylinder (h = 12, r=5.2/2, center = true);
    */

translate([9,-9- 0,0])
{
  //   translate([110,- 0,0])  cylinder (h = 12, r=5.2/2, center = true);
 translate([110,-75+HHXX,0])  cylinder (h = 12, r=5.2/2, center = true);
 translate([70,-75+HHXX,0])  cylinder (h = 12, r=5.2/2, center = true);
 translate([30,-75+HHXX,0])  cylinder (h = 12, r=5.2/2, center = true);
 translate([ -10,-75+HHXX,0])  cylinder (h = 12, r=5.2/2, center = true);


 translate([110,-65+HHXX,0])  cylinder (h = 12, r=5.2/2, center = true);
 translate([70,-65+HHXX,0])  cylinder (h = 12, r=5.2/2, center = true);
 translate([30,-65+HHXX,0])  cylinder (h = 12, r=5.2/2, center = true);
 translate([ -10,-65+HHXX,0])  cylinder (h = 12, r=5.2/2, center = true);
    
    
}




  }
  
     //  X4C30X=42;
      //projection(cut = false)
       // translate([0,0,40]) Z42BYG(SEL=4, X4C30= X4C30X); //齿轮组
  // translate([152.7, -12.3 , 0])rotate([0, 0, 45])BOX4(LL=80 );
}


module Z4tArm3(modul, zahnzahl, breite, randbreite,RXC=8)
{
  JL = 12.24;
  hh = 50;

  d = modul * zahnzahl;
  r = d / 2;
  c = modul / 6;                          // Kopfspiel
  da = (modul < 1) ? d + (modul + c) * 2.2 : d + (modul + c) * 2; // Kopfkreisdurchmesser
  ra = da / 2;
  RRRX =  ra + randbreite;



  XRR = 4.8;

  rotate([0, 0, -30]) translate([0, 0, 0])difference()
  {

    cylinder (h = 1, r = RRRX * 5.5 / 10, center = true);

    translate([0, 0, 0]) rotate([0, 0, 0]) cylinder (h = 2, r = RRRX * 3.5 / 10, center = true)


   
     translate([0, 0, 0]) rotate([0, 0, 0]) cylinder (h = 2, r = RXC / 2, center = true);

 SanJiao(XRR=4.8);
       

  }

  translate([0, 70-10 , 0])rotate([0, 0, 0])difference()
  {
    union()
    {
      translate([0, 30, 0])  cylinder (h = 1, r = 30/ 2, center = true);
      color("blue")  translate([0, -25+32, 0]) cube([26, 30+30, 1], center = true);
    }
     translate([0, 30, 0])cylinder (h = 2, r = RXC/ 2, center = true);
  }




}


module Z4tArm30(modul, zahnzahl, breite, randbreite,RXC=8)
{
  JL = 12.24;
  hh = 50;

  d = modul * zahnzahl;
  r = d / 2;
  c = modul / 6;                          // Kopfspiel
  da = (modul < 1) ? d + (modul + c) * 2.2 : d + (modul + c) * 2; // Kopfkreisdurchmesser
  ra = da / 2;
  RRRX =  ra + randbreite;



  XRR = 4.8;

  rotate([0, 0, -30]) translate([0, 0, 0])difference()
  {

    cylinder (h = 1, r = RRRX * 5.5 / 10, center = true);

    translate([0, 0, 0]) rotate([0, 0, 0]) cylinder (h = 2, r = RRRX * 3.5 / 10, center = true)


   
    translate([0, 0, 0]) rotate([0, 0, 0]) cylinder (h = 2, r = RXC / 2, center = true);

 for (rot = [0:20:360]) {
   X4C30X=42;
     rotate([0, 0, rot])   Z42BYG(SEL=5, X4C30= X4C30X); //齿轮组;
       
 }
  }

  translate([0, 70-10+5, 0])rotate([0, 0, 0])difference()
  {
    union()
    {
      translate([0, 6, 0])  cylinder (h = 1, r = 16/ 2, center = true);
      color("blue")  translate([0, -25 +15, 0]) cube([16,  33, 1], center = true);
    }
      translate([0, 30, 0])cylinder (h = 2, r = RXC/ 2, center = true);
    
      translate([0, -5, 0]) cube([2.3, 28, 4], center = true);
  }




}

module Z4tArmBi_Rshort(LL=50)
{


  // translate([250-6,-50-13,19]) rotate([0,0,20])difference()

  translate([0, 0,0]) rotate([0, 0, 0])difference()
  {
    union()
    {
      translate([LL/2+20/4, 0, 0])  cylinder (h = 1, r = 20 / 2, center = true);
      translate([-LL/2-20/4, 0, 0])  cylinder (h = 1, r = 20 / 2, center = true);
      translate([ 0, 0, 0]) cube([LL , 18, 1], center = true);
    
        
        
 
        
        
        }


    translate([LL/2+20/4, 0, 0])
 cylinder (h = 20, r=11.7/2, center = true);

    translate([-LL/2-20/4, 0, 0])
 cylinder (h = 20, r=11.7/2, center = true);

  translate([0, 0, 0])
 cylinder (h = 20, r=3/2, center = true);
        
    translate([LL/4+20/4, 0, 0])
 cylinder (h = 20, r=3/2, center = true);

    translate([-LL/4-20/4, 0, 0])
 cylinder (h = 20, r=3/2, center = true);


 // for (rot = [0:10]) {
          
        

   //     translate([ -LL/2+ LL *rot/5 , 0, 0]) cylinder (h = 10, r =3 / 2, //center = true);
     // }
    //   translate([31/2,31/2,0]) cylinder (h = 2, r=3.2/2, center = true);
    // translate([-31/2,31/2,0]) cylinder (h = 2, r=3.2/2, center = true);
    // translate([31/2,-31/2,0]) cylinder (h = 2, r=3.2/2, center = true);
    //  translate([-31/2,-31/2,0]) cylinder (h = 2, r=3.2/2, center = true);

  }





}


module Z4tArm4(modul, zahnzahl, breite, randbreite)
{
  JL = 12.24;
  hh = 50;

  d = modul * zahnzahl;
  r = d / 2;
  c = modul / 6;                          // Kopfspiel
  da = (modul < 1) ? d + (modul + c) * 2.2 : d + (modul + c) * 2; // Kopfkreisdurchmesser
  ra = da / 2;
  RRRX =  ra + randbreite;



  XRR = 4.7;

  rotate([0, 0, 30]) translate([0, 0, 0])difference()
  {

    cylinder (h = 1, r = RRRX * 5.5 / 10, center = true);

    translate([0, 0, 0]) rotate([0, 0, 0]) cylinder (h = 2, r = RRRX * 3.5 / 10, center = true);

    //  translate([0,0,0]) rotate([0,0,0]) cylinder (h = 20, r=1, center = true);


  translate([0,0,0]) rotate([0,0,0]) cylinder (h = 30, r=1/2, center = true);

 SanJiao(XRR=4.7);


  }

  translate([0, 70, 0])difference()
  {
    union()
    {
      translate([0, 42, 0])  cylinder (h = 1, r = 30 / 2, center = true);
      color("blue")  translate([0, -5.5, 0]) cube([30, 90, 1], center = true);
    }


    translate([0, 40, 0]) {
      cylinder (h = 2, r = 8 / 2, center = true);
      //   translate([31/2,31/2,0]) cylinder (h = 2, r=3.2/2, center = true);
      // translate([-31/2,31/2,0]) cylinder (h = 2, r=3.2/2, center = true);
      // translate([31/2,-31/2,0]) cylinder (h = 2, r=3.2/2, center = true);
      //  translate([-31/2,-31/2,0]) cylinder (h = 2, r=3.2/2, center = true);

    }
  }



}

module ZHUZI(ZJ=5)
{

 for (a =[0:36:360])  // 3 3.5 4 4.5 5
 {
      rotate([0, 0, a])
     {
 translate([25/2, 0, 0]) cylinder (h = 10, r =ZJ / 2, center = true);

 translate([-25/2, 0, 0]) cylinder (h = 10, r =ZJ / 2, center = true);
     }
 }

}

 


  //臂 2 曲柄
module BOX1( )
{
   {
  HHH = 0;
   difference() {
    zahnzahl_hohlrad = zahnzahl_sonne + 2 * zahnzahl_planet;
    union()
    {
      //projection(cut = false)
     color("blue")Z4tArm(modul, zahnzahl_hohlrad, breite, randbreite); //顶盖
    }
    translate([70, -125, 0])
 kongWai(modul, zahnzahl_hohlrad, breite, randbreite);
   // translate([70, -125, 0])   kongNei(modul, zahnzahl_hohlrad, breite, randbreite);
    
    
      for (rot = [0:2:11]) {
          
          translate([ 83+ rot*40, 18, 0]) cylinder (h = 100, r =3 / 2, center = true);

         translate([83+ rot*40, -18, 0]) cylinder (h = 10, r =3 / 2, center = true);
      }
    
    
    
    
  }
  
  translate([330,  37, 0])BOX4(LL=352 );
} 
    
    
}





//连接头  小臂1
module BOX2( )
{

  HHH = 10;
  difference() {
    zahnzahl_hohlrad = zahnzahl_sonne + 2 * zahnzahl_planet;
    union()
    {
      //projection(cut = false)
      translate([0, 0, HHH * 2])color("blue")Z4tArm24(modul, zahnzahl_hohlrad, breite, randbreite); //顶盖
    }
 
  }
}


 


  //dizuo 
module BOX3( )
{

  HHH = 10;

  translate([150, 150, 0])
    
    
     {   
  difference() {
    zahnzahl_hohlrad = zahnzahl_sonne + 2 * zahnzahl_planet;
    union()
    {
      //projection(cut = false)
      translate([0, 0,0])color("blue")Z4tArm2(modul, zahnzahl_hohlrad, breite, randbreite); //顶盖
        
     //   translate([151.7, -13.1 , 0])rotate([0, 0, 45])BOX4(LL=80 );
       
    }

    kongWai(modul, zahnzahl_hohlrad, breite, randbreite);
 //   kongNei(modul, zahnzahl_hohlrad, breite, randbreite);
    
    
   //  translate([140,-24,0]) rotate([0,0,45]) cube([40, 95, 4], center = true);
    
  }
  
  
  }
  
}


 

  //臂  1旋转 电机
module BOX4(LL=50 )
{


  Z4tArmBi_Rshort(LL);

}


 

//臂  25


module BOX5( ){

  Z4tArm25();

}



 //  电机  曲柄

module BOX6( ) 
{
  HHH = 10;
  translate([ 50, 100, 0])
  difference() {
    zahnzahl_hohlrad = zahnzahl_sonne + 2 * zahnzahl_planet;
    union()
    {
      //projection(cut = false)
      translate([0, 0, HHH * 2])color("blue")Z4tArm3(modul, zahnzahl_hohlrad, breite, randbreite,7.8); //顶盖
    }

// kongWai(modul, zahnzahl_hohlrad, breite, randbreite);
    //  kongNei(modul, zahnzahl_hohlrad, breite, randbreite);
  }
}


 //  限位开关

module BOX60( ) 
{
  HHH = 10;
  translate([ 50, 100, 0])
  difference() {
    zahnzahl_hohlrad = zahnzahl_sonne + 2 * zahnzahl_planet;
    union()
    {
      //projection(cut = false)
      translate([0, 0, HHH * 2])color("blue")Z4tArm30(modul, zahnzahl_hohlrad, breite, randbreite,7.8); //顶盖
    }

// kongWai(modul, zahnzahl_hohlrad, breite, randbreite);
    //  kongNei(modul, zahnzahl_hohlrad, breite, randbreite);
  }
}



//  臂 2


module BOX7( ) 
{

HHH = 10;
  translate([ 50, 100, 0])
  difference() {
    zahnzahl_hohlrad = zahnzahl_sonne + 2 * zahnzahl_planet;
    union()
    {
      //projection(cut = false)
      translate([0, 0, HHH * 2])color("blue")Z4tArm3(modul, zahnzahl_hohlrad, breite, randbreite,11.8); //顶盖
    }


// kongWai(modul, zahnzahl_hohlrad, breite, randbreite);
}
}



 //  臂 2
module BOX8( ) 
{
      HHH = 0;
    
  translate([ 0, -35, 0])
    {
  difference() {
    zahnzahl_hohlrad = zahnzahl_sonne + 2 * zahnzahl_planet;
    union()
    {
      //projection(cut = false)
      translate([0, 0, HHH * 2])color("blue")Z4tArmBi2(modul, zahnzahl_hohlrad, breite, randbreite); //
    }
    
    
      for (rot = [0:2:10]) {
          
           translate([ 120+ rot*40, 18, 0]) cylinder (h = 100, r =3 / 2, center = true);

         translate([120+ rot*40, -18, 0]) cylinder (h = 10, r =3 / 2, center = true);
      }

 kongWai(modul, zahnzahl_hohlrad, breite, randbreite);
    //  kongNei(modul, zahnzahl_hohlrad, breite, randbreite);
  }


  translate([250,  37, 0])BOX4(LL=305 );

}
}




  //  底座
module BOX9( ) 
{
     HHH = 10;
  difference() {
    zahnzahl_hohlrad = zahnzahl_sonne + 2 * zahnzahl_planet;
 
      //projection(cut = false)
    //  translate([0, 0, 0])color("Indigo") Z4o1(modul, zahnzahl_hohlrad, breite, randbreite); //中间转 片
  }
  
      HHH = 10;
  difference() {
    zahnzahl_hohlrad = zahnzahl_sonne + 2 * zahnzahl_planet;
 
      //projection(cut = false)
      translate([150, 0, 0])color("Indigo") Z4o2(modul, zahnzahl_hohlrad, breite, randbreite); //中间转 片
  }
  
}

 //轴承
module BOX36( ) 
{
    
       translate([  0,  0, 0]) cylinder (h = 12, r=8/2, center = true);
 
     translate([  0, 36/2, 0]) cylinder (h = 12, r=5/2, center = true);
     translate([  0, -36/2, 0]) cylinder (h = 12, r=5/2, center = true);
    
     translate([  36/2,0,  0]) cylinder (h = 12, r=5/2, center = true);
     translate([ -36/2, 0,  0]) cylinder (h = 12, r=5/2, center = true);
    
}
 //  底座竖版

module BOX10( ) 
{
    
    zahnzahl_hohlrad = zahnzahl_sonne + 2 * zahnzahl_planet;

      difference() {
          
             translate([0, -5, 0]) cube([100, 118+17, 1], center = true);
          
                  translate([0, -10, 0]) cube([42+22, 88 , 2], center = true);
          
        //       translate([60, 5, 0]) cube([30 , 80, 2], center = true);
        //     translate([-60, 5, 0]) cube([30 , 80, 2], center = true);
          
          
      translate([-0, 30,0]) rotate([0, 0, 90])  kongWai(modul, zahnzahl_hohlrad, breite, randbreite);
           
             translate([-0, 117,0]) rotate([0, 0,  0])  kongWai(modul, zahnzahl_hohlrad, breite, randbreite);
          
          
             translate([ 0,  30, 0]) cube([68, 1, 2], center = true);
          
             translate([ -49,  30, 0]) cube([3, 1, 2], center = true);
              translate([  49,  30, 0]) cube([3, 1, 2], center = true);
          
             translate([ -20,  56, 0]) cylinder (h = 12, r=8/2, center = true);
  translate([ 20,  56, 0])  cylinder (h = 12, r=8/2, center = true);
          
            translate([  0,  56, 0])  cylinder (h = 12, r=8/2, center = true);
          
          
       /*   translate([-50,-17,0])
{
  //   translate([110,- 0,0])  cylinder (h = 12, r=5.2/2, center = true);
 translate([110,-75+HHXX,0])  cylinder (h = 12, r=5.2/2, center = true);
 translate([70,-75+HHXX,0])  cylinder (h = 12, r=5.2/2, center = true);
 translate([30,-75+HHXX,0])  cylinder (h = 12, r=5.2/2, center = true);
 translate([ -10,-75+HHXX,0])  cylinder (h = 12, r=5.2/2, center = true);


 translate([110,-65+HHXX,0])  cylinder (h = 12, r=5.2/2, center = true);
 translate([70,-65+HHXX,0])  cylinder (h = 12, r=5.2/2, center = true);
 translate([30,-65+HHXX,0])  cylinder (h = 12, r=5.2/2, center = true);
 translate([ -10,-65+HHXX,0])  cylinder (h = 12, r=5.2/2, center = true);
    
    
}*/
      }
}

module BOXLUNZI( ) 
{
    
    //轮子 15cm
     translate([  0 , 0 ,  0])
    {
        
         for (rot = [0: 20:360]) {
                   
              rotate([0, 0, rot]) 
                   {
                       
                       
                         //钉子
                        translate([ 54,  0, 0])
                       {
                            difference() {
                            union()
                            {
                                    translate([  3.5,  -12, 0]) cube([11.5, 2, 2], center = true);                                  
                                    translate([  3.8,  -5, 0]) cube([5.2, 16, 2], center = true);
                            }
                                    translate([3.8,0.2,0]) cylinder (h =10, r=2.8/2, center = true);   
                        }
                       }
                   }
               }
        
        
              difference() {
                
                  union()
                  {
                  for (rot = [0: 30:360]) {
                   
              rotate([0, 0, rot]) 
                   {
                       
                
                       
                       
                       
                       //臂
                        difference() {
                            union()
                            {
    
                               
                                 translate([ 42,  0, 0])
                                 { 
                                     cube([18, 6, 2], center = true);
                                      translate([  3.5,  -0.5, 0]) cube([11.5+1, 8, 2], center = true);                                  
                                      translate([  3.8,  -7.5, 0]) cube([7.7, 6.6, 2], center = true);
                                     
                                   
                                     
                                     
                                  //    #translate([  3.8,  -6.5, 0])cylinder (h =4, r=7.5/2, center = true); ;  
                                     
                                      %translate([  3.8,  -8.2, 0]) cube([22, 7, 2], center = true);
                                     
                                     
                                 }
                       //  translate([146/2,0,0]) cylinder (h =1, r=14/2, center = true); ;  
                       //           translate([-146/2,0,0]) cylinder (h =1, r=14/2, center = true); ;  
                       }
                       
                   # translate([ 45.5,  0, 0])cylinder (h =10, r=2.7/2, center = true);
                       
                        translate([146/2,0,0]) cylinder (h =2, r=7.5/2, center = true); ;  
                        translate([-146/2,0,0]) cylinder (h =2, r=7.5/2, center = true); ;  
                             
                        }
       
                       
                   }
                 }
                 cylinder (h =1, r=68/2, center = true);
                 
               //   %cylinder (h =1, r=84/2, center = true);
             //  %stirnrad (modul=2, zahnzahl=84/2, breite=3, bohrung1=18.8, eingriffswinkel=20, schraegungswinkel= 0);
                 
                 }
          
                rotate([0, 0, 15])   GEAR_22_8(  WAI=1 ) ;
            //  #  translate([0,0,0]) Z42BYG(SEL=5, X4C30= 4.6); //齿轮组
                 
                
         }
    
    }
}

 
module BOX11( ) 
{
    
    
      difference() {
            translate([90, 0, 0])  cylinder (h = 2, r = 24 / 2, center = true);
            translate([90, 0, 0])  cylinder (h = 2, r = 19 / 2, center = true);
      }
  }
  
 



//  垫片2
module BOX12( ) 
{
    
    
      difference() {
            translate([0, 0, 0])  cylinder (h = 2, r = 22 / 2, center = true);
            translate([0, 0, 0])  cylinder (h = 2, r = 8 / 2, center = true);
          
        //  ZHUZI(5);
      }
  }
  


  

//圆角矩形 
module createMeniscus(h,radius) // This module creates the shape that needs to be substracted from a cube to make its corners rounded.
difference(){        //This shape is basicly the difference between a quarter of cylinder and a cube
   translate([radius/2+0.1,radius/2+0.1,0]){
      cube([radius+0.2,radius+0.1,h+0.2],center=true);         // All that 0.x numbers are to avoid "ghost boundaries" when substracting
   }

   cylinder(h=h+0.2,r=radius,$fn = 25,center=true);
}


module roundCornersCube(x,y,z,r)  // Now we just substract the shape we have created in the four corners
difference(){
   cube([x,y,z], center=true);

translate([x/2-r,y/2-r]){  // We move to the first corner (x,y)
      rotate(0){  
         createMeniscus(z,r); // And substract the meniscus
      }
   }
   translate([-x/2+r,y/2-r]){ // To the second corner (-x,y)
      rotate(90){
         createMeniscus(z,r); // But this time we have to rotate the meniscus 90 deg
      }
   }
      translate([-x/2+r,-y/2+r]){ // ... 
      rotate(180){
         createMeniscus(z,r);
      }
   }
      translate([x/2-r,-y/2+r]){
      rotate(270){
         createMeniscus(z,r);
      }
   }
}
  //  垫片3
module BOX13( ) 
{
    
    
      difference() {
            translate([0, 0, 0])  cylinder (h = 2, r = 22 / 2, center = true);
            translate([0, 0, 0])  cylinder (h = 2, r = 5 / 2, center = true);
          
        //  ZHUZI(5);
      }
  }
  
  
  //底盘零件
module BOXCAR3_NEW( ) 
{
    
      RR1=84;  //主动齿轮
        RR2 =84; //从动齿轮
    
    difference() {
       union()
         {
       HUANX(HRR=112, RX= 90  ); //80 -100
          
         translate([85 ,0, 0]) cube([30, 62, 1 ], center = true);
      
      /// cylinder (h =1, r=RR1/2, center = true);              
        stirnrad (modul=2, zahnzahl=RR1/2, breite=1, bohrung1=18.8, eingriffswinkel=20, schraegungswinkel= 0);
     
           
             }
             
                    #rotate([0,0, 0])  translate([ RR2 +(RR1-RR2)/2,0,0]) 
       {
           
         //   GEAR_22_8(  ) ;
            cylinder (h =5, r=7.8/2, center = true);  
      // cylinder (h =1, r=RR2/2, center = true);   
          //  cylinder (h =30, r=16/2, center = true);
            % stirnrad (modul=2, zahnzahl=RR2/2, breite=1, bohrung1=18.8, eingriffswinkel=20, schraegungswinkel= 0);
     
       }
           
             
           Z42BYG(SEL=5, X4C30= 4.6); //齿轮组
      
          GEAR_22_8(  WAI=1 ) ;
     
      }
      
      
  
}

//齿轮安装参数        齿轮外径   齿轮转动孔大小
module GEAR_22_8(  WAI=1 ) 
{
     
     cylinder (h =5, r=18.5/2, center = true);  
    
      for (rot = [0:60:360]) {
            rotate([0,0, rot])  translate([30/2 ,0,0])  cylinder (h =5, r=3/2, center = true);  
       if(WAI==1)
       {
          rotate([0,0, rot])  translate([30,0,0])  cylinder (h =5, r=5/2, center = true);  
       }
       }
}

//不锈钢折叠区域
module ZHEBUXIUGANG( Ju=1 ) 
{
    translate([0,28, 0])   difference() {
             cube([11, 6, 3], center = true);
    
          translate([ Ju,3, 0])  cube([1, 1, 4], center = true);
          
           translate([ Ju,-3, 0])  cube([1, 1, 4], center = true);
      }
      
      
       translate([0, -28, 0])   difference() {
             cube([11, 6, 3], center = true);
    
          translate([ Ju,3, 0])  cube([1, 1, 4], center = true);
          
           translate([ Ju,-3, 0])  cube([1, 1, 4], center = true);
      }
}

      //  机身
module BOXCAR3A(  ) 
{
    

     difference() {
       union()
         {
              translate([0, 0, 0])  cylinder (h = 2, r = 280 / 2, center = true,$fn=99); 
             
           rotate([0,0,  0]){

                 translate([141.5, 0, 0])ZHEBUXIUGANG(  ) ;
             translate([ 213 ,0,0])rotate([0,0,0]) BOXCAR3_NEW( ) ;
               }
               
                      rotate([0,0,  120]){       
              translate([141.5, 0, 0])ZHEBUXIUGANG(  ) ;            
             translate([ 213 ,0,0])rotate([0,0,0]) BOXCAR3_NEW( ) ;
               }      
 
                      rotate([0,0,  240]){     
            translate([141.5, 0, 0])ZHEBUXIUGANG(  ) ;              
             translate([ 213 ,0,0])rotate([0,0,0]) BOXCAR3_NEW( ) ;
               }       
                                                 
                                                     
         }
         
        // 8mm 固定孔
  # for (rot = [0:60:360]) {
      rotate([0,0, rot])  translate([120,0,0]) cylinder (h =20, r=8/2, center = true);         
      rotate([0,0, rot])  translate([90,0,0]) cylinder (h =20, r=8/2, center = true);              
     } 
     

     //大孔 
       # for (rot = [0:180:360]) {           
      rotate([0,0, rot+ 0])  translate([75,0,0]) cylinder (h =20, r=80/2, center = true);   
   
     } 
     
    
     #  translate([0,0,0]) Z42BYG(SEL=5, X4C30= 4.6); //齿轮组
         
       #kongWai( );
    //  #kongNei( );
     
     
      }
  }
  
  
  
        //摄像头机架
module  CamBox(  ) 
{
    
     difference() {
       union()
         {
           translate([0,142,0]) cube([136, 40, 1], center = true);         
            translate([40,-227,0]) cube([25, 700, 1], center = true);             
            translate([-40,-227,0]) cube([25, 700, 1], center = true);                                         }
         
        // 8mm 固定孔
   translate([0,50,0])# for (rot = [0:60:360]) {
      rotate([0,0, rot])  translate([120,0,0]) cylinder (h =20, r=8/2, center = true);       
      rotate([0,0, rot])  translate([90,0,0]) cylinder (h =20, r=8/2, center = true);               } 
     
      
        #translate([0,121,0]) cube([68, 1, 1], center = true);         
      
        #translate([53,121,0]) cube([11, 1, 1], center = true);    
        #translate([-53,121,0]) cube([11, 1, 1], center = true);    
      
      
        #translate([0,-621,0])
      {
      #translate([0,121,0]) cube([68, 1, 1], center = true);         
      
        #translate([53,121,0]) cube([11, 1, 1], center = true);    
        #translate([-53,121,0]) cube([11, 1, 1], center = true);    
      }
      
      }
      
  
translate([0,-593,0])
       difference() {
            cube([136, 40, 1], center = true);
         
        // 8mm 固定孔
  # for (rot = [0:20:100]) {
       translate([-50+rot,10,0]) cylinder (h =20, r=5/2, center = true);       
           
        translate([-50+rot,-10,0]) cylinder (h =20, r=5/2, center = true);               } 
     
      } 
      
  }
  
  
  
          //分级
module  CamBoxFJ(  ) 
{
    
     difference() {
       union()
         {
           translate([0,142,0]) cube([136, 40, 1], center = true);     
         
           translate([36,94,0]) cube([60, 60, 1], center = true); 
             
            translate([100,20+33,0]) cube([200,25,  1], center = true);             
            translate([100,-20+33,0]) cube([200,25,  1], center = true);



translate([0,0,0])  for (rot = [0:30:190]) {
      translate([10+rot,30,0]) cube([5,35,  1], center = true);               
        } 
translate([23,33,0]) cube([10,160,  1], center = true);   
translate([10,33,0]) cube([10,160,  1], center = true);   
translate([200,33,0]) cube([10,160,  1], center = true);  
       translate([200-13,33,0]) cube([10,160,  1], center = true);   
             }
         
        // 8mm 固定孔
   translate([0,234,0])# for (rot = [0:60:360]) {
      rotate([0,0, rot])  translate([120,0,0]) cylinder (h =20, r=8/2, center = true);       
      rotate([0,0, rot])  translate([90,0,0]) cylinder (h =20, r=8/2, center = true);               } 
     
      
      
      
       translate([0,0,0])# for (rot = [0:90:190]) {
      translate([10+rot,20+33,0]) cylinder (h =20, r=5/2, center = true);       
       translate([10+rot,-20+33,0])cylinder (h =20, r=5/2, center = true);               } 
       
       
         # translate([ 200,72+33,0]) cylinder (h =20, r=5/2, center = true);       
       #translate([ 200,-72+33,0])cylinder (h =20, r=5/2, center = true);
       
        # translate([ 200-13,72+33,0]) cylinder (h =20, r=5/2, center = true);       
       #translate([ 200-13,-72+33,0])cylinder (h =20, r=5/2, center = true);
       
       
       # translate([ 10,72+33,0]) cylinder (h =20, r=5/2, center = true);       
       #translate([ 10,-72+33,0])cylinder (h =20, r=5/2, center = true);
       
         # translate([ 23,72+33,0]) cylinder (h =20, r=5/2, center = true);       
       #translate([ 23,-72+33,0])cylinder (h =20, r=5/2, center = true);
      
     //   #translate([0,121,0]) cube([68, 1, 1], center = true);         
      
     //   #translate([53,121,0]) cube([11, 1, 1], center = true);    
      //  #translate([-53,121,0]) cube([11, 1, 1], center = true);    
      
      
        #translate([0,-621,0])
      {
      #translate([0,121,0]) cube([68, 1, 1], center = true);         
      
        #translate([53,121,0]) cube([11, 1, 1], center = true);    
        #translate([-53,121,0]) cube([11, 1, 1], center = true);    
      }
      
      }
      
  
      /*
translate([0,-593,0])
       difference() {
            cube([136, 40, 1], center = true);
         
        // 8mm 固定孔
  # for (rot = [0:20:100]) {
       translate([-50+rot,10,0]) cylinder (h =20, r=5/2, center = true);       
           
        translate([-50+rot,-10,0]) cylinder (h =20, r=5/2, center = true);               } 
     
      } */
      
  }
  
  
  
  
        //  机身
module BOXCAR3B(  ) 
{
    

     difference() {
       union()
         {
              translate([0, 0, 0])  cylinder (h = 2, r = 280 / 2, center = true,$fn=99); 
             
           rotate([0,0,  0]){

                 translate([141.5, 0, 0])ZHEBUXIUGANG( Ju=-1 ) ;
             translate([ 242.5 ,0,0])rotate([0,0,180]) BOXCAR3_NEW( ) ;
               }
               
                      rotate([0,0,  120]){       
              translate([141.5, 0, 0])ZHEBUXIUGANG( Ju=-1 ) ;            
             translate([ 242.5 ,0,0])rotate([0,0,180]) BOXCAR3_NEW( ) ;
               }      
 
                      rotate([0,0,  240]){     
            translate([141.5, 0, 0])ZHEBUXIUGANG(Ju=-1  ) ;              
             translate([ 242.5 ,0,0])rotate([0,0,180]) BOXCAR3_NEW( ) ;
               }       
                                                 
                                                     
         }
         
        // 8mm 固定孔
  # for (rot = [0:60:360]) {
      rotate([0,0, rot])  translate([120,0,0]) cylinder (h =20, r=8/2, center = true);         
      rotate([0,0, rot])  translate([90,0,0]) cylinder (h =20, r=8/2, center = true);              
     } 
     

     //大孔 
       # for (rot = [0:180:360]) {           
      rotate([0,0, rot+ 0])  translate([75,0,0]) cylinder (h =20, r=80/2, center = true);   
   
     } 
     
    
     #  translate([0,0,0]) Z42BYG(SEL=5, X4C30= 4.6); //齿轮组
         
       #kongWai( );
    //  #kongNei( );
     
     
      }
  }
      /*
        RR1=84;  //主动齿轮
        RR2 =84; //从动齿轮
      
       %rotate([0,0, 0])  translate([212,0,0]) {
           cylinder (h =1, r=RR1/2, center = true);   
            
    rotate([0,0, 2.5])   stirnrad (modul=2, zahnzahl=RR1/2, breite=1, bohrung1=18.8, eingriffswinkel=20, schraegungswinkel= 0);
     
           Z42BYG(SEL=5, X4C30= 4.6); //齿轮组
       }
       
       %rotate([0,0, 0])  translate([212+RR2 +(RR1-RR2)/2,0,0]) 
       {
       cylinder (h =1, r=RR2/2, center = true);   
            cylinder (h =3, r=16/2, center = true);
            stirnrad (modul=2, zahnzahl=RR2/2, breite=1, bohrung1=18.8, eingriffswinkel=20, schraegungswinkel= 0);
     
       }
       
       */
      
 
  
    //  机身
module BOXCAR(ADDXC=1.2 ) 
{
    
    //底座1
    difference() {
        
        union()
        {
   //机身
    translate([-110,  0, 0])  roundCornersCube(400,200,2,40);
    
            
   translate([-0,0,0])
   {
       //齿轮环  长方形
    translate([-210,165+ADDXC,0])rotate([0,0,  0]) HUANX( RX= 90 );
    
    //齿轮环  长方形
    translate([-210,-165-ADDXC,0])rotate([0,0, 0]) HUANX( RX= 90 );
      
     translate([-210+60, 0, 0]) cube([20, 270, 1], center = true);
     translate([-210 , 0, 0]) cube([20, 230, 1], center = true);
     translate([-210-60, 0, 0]) cube([20, 270, 1], center = true);
   }
       
    translate([200,0,0])
   {
       //齿轮环  长方形
    translate([-210,165+ADDXC,0])rotate([0,0,  0]) HUANX( RX= 90 );
    
    //齿轮环  长方形
    translate([-210,-165-ADDXC,0])rotate([0,0, 0]) HUANX( RX= 90 );
      
     translate([-210+60, 0, 0]) cube([20, 270, 1], center = true);
     translate([-210 , 0, 0]) cube([20, 230, 1], center = true);
     translate([-210-60, 0, 0]) cube([20, 270, 1], center = true);
   }

   
            
     }
      
       translate([-0,0,0])
   {
       translate([-240 ,100.5, 0]) cube([48, 1, 41], center = true);
     translate([-240 ,-100.5, 0]) cube([48, 1, 41], center = true);
    
    
         translate([-180 ,100.5, 0]) cube([48, 1, 41], center = true);
     translate([-180 ,-100.5, 0]) cube([48, 1, 41], center = true);
      
      
         translate([-279 ,100.5, 0]) cube([5, 1, 41], center = true);
      translate([-279 ,-100.5, 0]) cube([5, 1, 41], center = true);
    
    
          translate([-140 ,100.5, 0]) cube([5, 1, 41], center = true);
     translate([-140 ,-100.5, 0]) cube([5, 1, 41], center = true);
   }
   
   
          translate([ 200,0,0])
   {
       translate([-240 ,100.5, 0]) cube([48, 1, 41], center = true);
     translate([-240 ,-100.5, 0]) cube([48, 1, 41], center = true);
    
    
         translate([-180 ,100.5, 0]) cube([48, 1, 41], center = true);
     translate([-180 ,-100.5, 0]) cube([48, 1, 41], center = true);
      
      
         translate([-279 ,100.5, 0]) cube([5, 1, 41], center = true);
      translate([-279 ,-100.5, 0]) cube([5, 1, 41], center = true);
    
    
          translate([-140 ,100.5, 0]) cube([5, 1, 41], center = true);
     translate([-140 ,-100.5, 0]) cube([5, 1, 41], center = true);
   }
   
      
      
     # for (rot = [0:40:360]) {
                translate([rot -290,40,0]) cylinder (h =20, r=8/2, center = true);   //齿轮组;
                
                 translate([rot -290,-40,0]) cylinder (h =20, r=8/2, center = true);   //齿轮组;
                 
                   translate([rot -290, 0,0]) cylinder (h =20, r=8/2, center = true);   //齿轮组;
                 
                 
                  translate([rot -290,80,0]) cylinder (h =20, r=8/2, center = true);   //齿轮组;
                  
                   translate([rot -290,-80,0]) cylinder (h =20, r=8/2, center = true);   //齿轮组;
                
      }
      
      
       translate([0,0,0])rotate([0,0,  30]) Z42BYG(SEL=5, X4C30= 4.7); //齿轮组
      
       translate([-80,0,0]) rotate([0,0,  30]) Z42BYG(SEL=5, X4C30= 4.7); //齿轮组
      
        translate([-160,0,0])rotate([0,0,  30])  Z42BYG(SEL=5, X4C30= 4.7); //齿轮组
      
         translate([-240,0,0])rotate([0,0,  30])  Z42BYG(SEL=5, X4C30= 4.7); //齿轮组
      
    }
    
    
}
  //

if (SHOW == 0)
{
  HHH = 10;
  difference() {
    zahnzahl_hohlrad = zahnzahl_sonne + 2 * zahnzahl_planet;
    union()
    {
        X4C30X=42;
      //projection(cut = false)
       translate([0,0,0]) Z42BYG(SEL=0, X4C30= X4C30X); //齿轮组



     translate([0, 0, -15])color("LawnGreen")Z4(modul, zahnzahl_hohlrad- X4C30X-20, breite, randbreite); //底环  42BYG 固定


      //projection(cut = false)
   //   translate([0, 0, -HHH * 1])color("Indigo") Z4o(modul, zahnzahl_hohlrad, breite, randbreite); //中间转 片

       //projection(cut = false)
         translate([0,0,19])color("Indigo")Z4o(); //中间转 片

   translate([0,0,-4])color("Indigo")Z4o(); //中间转 片

//齿轮环  长方形
    translate([0,0,17])rotate([0,0,90]) HUANX( RX= 90 );

//齿轮环  长方形
    translate([0,0, 3])rotate([0,0,90]) HUANX( RX= 90 );

// 轮环   
    translate([0,0,10])  HUAN9575(  );
      //projection(cut = false)
      //  translate([0,0,HHH*2])color("blue")Z4t(modul, zahnzahl_hohlrad, breite, randbreite); //顶盖

      //projection(cut = false)
     //    translate([0,0,-HHH*2])color("blue")Z4t(modul, zahnzahl_hohlrad- X4C30X, breite, randbreite); //底环垫片
    }

 kongWai(modul, zahnzahl_hohlrad, breite, randbreite);
 kongNei(modul, zahnzahl_hohlrad, breite, randbreite);
  }
}



if (SHOW == 1)  //projection(cut = false)
{
  HHH = 10;
  //difference() {
    zahnzahl_hohlrad = zahnzahl_sonne + 2 * zahnzahl_planet;
     
        X4C30X=42;
      //projection(cut = false)
        translate([0,0,0]) Z42BYG(SEL=0, X4C30= X4C30X); //齿轮组


 
     translate([100, 0, -15])color("LawnGreen")Z4(modul, zahnzahl_hohlrad- X4C30X-20, breite, randbreite); //底环  42BYG 固定

 

      //projection(cut = false)
   //   translate([0, 0, -HHH * 1])color("Indigo") Z4o(modul, zahnzahl_hohlrad, breite, randbreite); //中间转 片

       //projection(cut = false)
         translate([0,-150,0])color("Indigo")Z4o( RRXXC= 80); //中间转 片

   translate([-110,0, 0])color("Indigo")Z4o( RRXXC= 80); //中间转 片

  translate([-110,-150, 0])color("Indigo")Z4o( RRXXC= 85); //中间转 片
  
  translate([ 110, -150, 0])color("Indigo")Z4o( RRXXC= 85); //中间转 片
  
//齿轮环  长方形
    //translate([-110,-150,17])rotate([0,0,90]) HUANX( RX= 95 ); //75 -95 
    translate([-113,-150,0])rotate([0,0,90]) HUANX(HRR=112, RX= 100 ); //80 -100
//齿轮环  长方形
   // translate([00,-150,17])rotate([0,0,90]) HUANX( RX= 95 );
     translate([113,-150,0])rotate([0,0,90]) HUANX( HRR=112, RX= 100 );//80 -100

//齿轮环  长方形
    translate([-110,0,0])rotate([0,0,90]) HUANX( RX= 90 );

//齿轮环  长方形
    translate([0,0, 3])rotate([0,0,90]) HUANX( RX= 90 );

// 轮环   
  //  translate([0,0,10])  HUAN9575(  );
      //projection(cut = false)
      //  translate([0,0,HHH*2])color("blue")Z4t(modul, zahnzahl_hohlrad, breite, randbreite); //顶盖

      //projection(cut = false)
     //    translate([0,0,-HHH*2])color("blue")Z4t(modul, zahnzahl_hohlrad- X4C30X, breite, randbreite); //底环垫片
    

// kongWai(modul, zahnzahl_hohlrad, breite, randbreite);
// kongNei(modul, zahnzahl_hohlrad, breite, randbreite);
  //}
}


if (SHOW == 101)
  // projection(cut = false)
{


  HHH = 166;
  
    zahnzahl_hohlrad = zahnzahl_sonne + 2 * zahnzahl_planet;
 

      //projection(cut = false)
      translate([-HHH * 1, 0, 0 ])color("blue")difference() {

        Z4t(modul, zahnzahl_hohlrad, breite, randbreite,RRLL= 120); //底环垫片
 kongWai(modul, zahnzahl_hohlrad, breite, randbreite);
 kongNei(modul, zahnzahl_hohlrad, breite, randbreite);
          
          SanJiao(XRR=4.6);
      }
  


  


  HHH = 166;
  
    zahnzahl_hohlrad = zahnzahl_sonne + 2 * zahnzahl_planet;
 

      //projection(cut = false)
      translate([-HHH * 2, 0, 0 ])color("blue")difference() {

        Z4t00(modul, zahnzahl_hohlrad, breite, randbreite,RRLL= 110); //底环垫片
 kongWai(modul, zahnzahl_hohlrad, breite, randbreite);
 kongNei(modul, zahnzahl_hohlrad, breite, randbreite);
          
          SanJiao(XRR=4.6);
      }
  

      //projection(cut = false)
      translate([-HHH * 3, 0, 0 ])color("blue")difference() {

        Z4t(modul, zahnzahl_hohlrad, breite, randbreite,RRLL= 120); //底环垫片
 kongWai(modul, zahnzahl_hohlrad, breite, randbreite);
 kongNei(modul, zahnzahl_hohlrad, breite, randbreite);
          
          SanJiao(XRR=4.6);
      }
  
   //projection(cut = false)
      translate([ 0  , 0, 0 ])color("blue")difference() {

        Z4t(modul, zahnzahl_hohlrad, breite, randbreite,RRLL= 120); //底环垫片
 kongWai(modul, zahnzahl_hohlrad, breite, randbreite);
 kongNei(modul, zahnzahl_hohlrad, breite, randbreite);
          
          SanJiao(XRR=4.6);
      }

  


  HHH = 166;
  
    zahnzahl_hohlrad = zahnzahl_sonne + 2 * zahnzahl_planet;
 

      //projection(cut = false)
      translate([-HHH * 4, 0, 0 ])color("blue")difference() {

        Z4t00(modul, zahnzahl_hohlrad, breite, randbreite,RRLL= 110); //底环垫片
 kongWai(modul, zahnzahl_hohlrad, breite, randbreite);
 kongNei(modul, zahnzahl_hohlrad, breite, randbreite);
          
          SanJiao(XRR=4.6);
      }

  }


if (SHOW == 2)
      //projection(cut = false)
{
   
 //   translate([0, 40, 0])BOX2();//连接头  小臂1

     translate([55, -240, 0])BOX3();//主底座电机
    
     translate([360, -240, 0])BOX3();//主底座电机
 
    
     translate([0, 2, 0])BOX1();//主曲柄臂
    
translate([320, 336 , 20])BOX4(LL=480 );//主臂连接
    
      translate([160, 0 , 0]){
           difference() {
       
       union()
        {
    //PX  前端   1
    translate([320, 136 , 20])BOX4(LL=80 );//PX1
    
     translate([320+45, 157, 20]) cube([90+90, 25,1], center = true);   
        
        }
        
          translate([310, 164 ,  20]){        
           #translate([ 35/2,0,  0 ]) cylinder (h = 12, r = 4.8 / 2, center = true);
           #translate([-35/2, 0,  0 ]) cylinder (h = 12, r = 4.8 / 2, center = true);
              
           #translate([ 35/2,-10,  0 ]) cylinder (h = 12, r = 4.8 / 2, center = true);
           #translate([-35/2, -10,  0 ]) cylinder (h = 12, r = 4.8 / 2, center = true);
          }
          
           translate([370, 164 ,  20]){        
           #translate([ 35/2,0,  0 ]) cylinder (h = 12, r = 4.8 / 2, center = true);
           #translate([-35/2, 0,  0 ]) cylinder (h = 12, r = 4.8 / 2, center = true);
              
           #translate([ 35/2,-10,  0 ]) cylinder (h = 12, r = 4.8 / 2, center = true);
           #translate([-35/2, -10,  0 ]) cylinder (h = 12, r = 4.8 / 2, center = true);
          }
          
                   translate([430, 164 ,  20]){        
           #translate([ 35/2,0,  0 ]) cylinder (h = 12, r = 4.8 / 2, center = true);
           #translate([-35/2, 0,  0 ]) cylinder (h = 12, r = 4.8 / 2, center = true);
              
           #translate([ 35/2,-10,  0 ]) cylinder (h = 12, r = 4.8 / 2, center = true);
           #translate([-35/2, -10,  0 ]) cylinder (h = 12, r = 4.8 / 2, center = true);
          }
          
    }
          
}

/*
      translate([160+108, 0 , 0]){
           difference() {
       
       union()
        {
    //PX  前端   1
    translate([320, 136 , 20])BOX4(LL=80 );//PX1
  color("red")  translate([320 , 136+32 , 20])rotate([0, 0,  0])BOX4(LL=80 );//PX2
          
     translate([320, 152, 20]) cube([90, 15,1], center = true);   
        
        }
          # for (rot = [0:2:14]) {
          
             translate([285+rot*5, 152+20, 20]) cylinder (h = 100, r =3 / 2, center = true);

              translate([285+rot*5, 152-20, 20]) cylinder (h = 10, r =3 / 2, center = true);
        
          translate([285+rot*5, 152 , 20]) cylinder (h = 10, r =3 / 2, center = true);
      }
      
  }
}
*/

   
    difference() {
      //PX  zhong 端  
       union()
        {
        translate([320, 136 , 20])BOX4(LL=80 );//PX 
  color("red")  translate([320+77, 136+31.7 , 20])rotate([0, 0,  45])BOX4(LL=80 );//PX2
        }
         translate([ 275+90 , 136 , 20])cylinder (h = 60, r=11.7/2, center = true);
    }
 
   //    translate([320, 136 , 20])BOX4(LL=80 );//PX1
   // translate([320, 166 , 20])BOX4(LL=80 );//PX2
    
    
   //    translate([320, 136 , 20])BOX4(LL=80 );//PX1
   // translate([320, 166 , 20])BOX4(LL=80 );//PX2
    
    
    

// translate([340, -37, 20]) BOX5( );//平行线 手部固定器

translate([ -20, -390, 0])BOX6( );  //主底座电机 曲柄推杆

 translate([ 65, -390,   0])rotate([0, 0,  0])BOX7( ) ;//次级臂推杆 

  translate([0, 110, 20])BOX8( ) ; //  次臂+ 

translate([-90- 26, 210, 20])BOX9( ) ; //  底座

 //  底座竖版
 //translate([250+ 8, 180, 0])rotate([0, 0, -90])BOX10( ) ;


 //  底座竖版
// translate([370+28, 180, 0])rotate([0, 0, -90])BOX10( ) ;


 translate([130, 30,  0]) 
 {
//  垫片1
 translate([0, -140, 20]) BOX11( ) ;
 //  垫片1
 translate([0, -140+30, 20]) BOX11( ) ;
 //  垫片1
 translate([0-30, -140+30, 20]) BOX11( ) ;
 //  垫片1
 translate([0-30, -140, 20]) BOX11( ) ;
 }

  translate([30, -90, 0]) 
 {
   //  垫片2
translate([55, -50, 20])BOX12( );
   //  垫片2
translate([30, -50, 20])BOX12( );
 

   //  垫片2
translate([55, -20, 20])BOX13( );
   //  垫片2
translate([30, -20, 20])BOX13( );
 

}

 
}
  
//限位 转盘
if (SHOW == 3)
    // projection(cut = false)
{
    translate([ 0,  0, 0])BOX60( );  //主底座电机 曲柄推杆
    
    difference() {
    
       union()
       {
           translate([0, 0, 0]) cube([80, 10, 4], center = true);
           translate([35, 12, 0]) cube([10, 15, 4], center = true);
        
       }
       
        translate([0, 0, 0]) cube([70,3, 4], center = true);
           translate([35, 10, 0]) cube([2.3, 14, 4], center = true);
       
    }
    
    
     translate([0, 30, 0])   difference() {
    
       union()
       {
           translate([0, 0, 0]) cube([90, 16, 4], center = true);
           translate([35, 12, 0]) cube([10, 18, 4], center = true);
        
       }
       
        translate([0, 0, 0]) cube([70,8, 4], center = true);
           translate([35, 12, 0]) cube([2.3, 14, 4], center = true);
       
    }
    
    
}


//小车底盘
if (SHOW == 4)
   //projection(cut = false)
{
   //   translate([ 195, 140, 10]) BOXLUNZI( ) ;
  //   translate([ 0,   310, 10]) rotate([0, 180,  15])   BOXLUNZI( ) ;
    
    //   translate([410,  310, 0]) BOXLUNZI( ) ;
     // translate([ 200,   310, 0])    BOXLUNZI( ) ;
    
    
    
    //  机身
   BOXCAR3A( ADDXC= 1) ;
    
    translate([490,  00, 0])  BOXCAR3B( ADDXC= 1) ;
   // translate([410,  00, 0]) BOXCAR3(ADDXC= 3 );
    
    //stirnrad(modul, zahnzahl, breite, bohrung1, eingriffswinkel = 20, schraegungswinkel = 0, optimiert1 = false) 
    /*
   #  translate([211,0,2])
   stirnrad (modul=2, zahnzahl=84/2, breite=1, bohrung1=18.8, eingriffswinkel=20, schraegungswinkel= 0);
    
       # translate([211+84,0,0])
  rotate([0, 0, 5]) stirnrad (modul=2, zahnzahl=84/2, breite=1, bohrung1=18.8, eingriffswinkel=20, schraegungswinkel= 0);
    
     # translate([211+84+84,0,0])
  rotate([0, 0, 0]) stirnrad (modul=2, zahnzahl=84/2, breite=1, bohrung1=18.8, eingriffswinkel=20, schraegungswinkel= 0);*/
}

//轮子
if (SHOW == 5)
 //   projection(cut = false)
{
      translate([ 195, 140, 10]) BOXLUNZI( ) ;
    
    
    
}
//  projection(cut = false)translate([ 65, -390,   0])rotate([0, 0,  0])BOX7( ) ;//次级臂推杆 

//摄像头机架
if (SHOW ==6)
  // projection(cut = false)
{
    
   //摄像头机架
  CamBox() ;
 
}

if (SHOW ==7)
     projection(cut = false)
{
    
   //fenjjiji分级机
  CamBoxFJ() ;
 
}
