/*

Muenzwurf Beispiel Solidity, sven@zen-project.de (startet 11.07.2016)

26.August.2017 - remove deprecated 'throw',
                 make 'Einsatz_machen' payable.

todo: testing.

*/
pragma solidity ^0.4.15;  

contract kopf_oder_zahl  
{
address owner; 
 
int            status;
int     public wette_laeuft_gerade = 0;
uint256 public gewinnsumme = 0;
int     public number_spieler;
int     public counter_spieler = 0;
uint    public dauer_in_sekunden;
uint    public wetteinsatz_wei;
uint    public timestamp_start;
int     public verbleibende_sekunden;
address public debug_gewinner_adresse;

string msgbuffer;
string public spielregeln = "Einsatz: 1 Ether. Das Spiel beginnt, sobald alle Spieler ihre Einsaetze getattigt haben. Danach wird der komplette Topf an den Gewinner ausgeschuettet.";
  
Spielerstruct[] public Spieler;
  
struct Spielerstruct 
      {
      address adresse;
      string name;
      uint256 guthaben;
      }

    

/* -------------------------------------------------------------------

Konstruktor 

------------------------------------------------------------------- */
function kopf_oder_zahl (
                        int init_number_spieler,
                        uint init_dauer_in_sekunden,
                        uint init_wetteinsatz_ether
                        )
                        {
                            
                        owner = msg.sender;
                        status = 0;
                        number_spieler    = init_number_spieler;
                        dauer_in_sekunden = init_dauer_in_sekunden;
                        wetteinsatz_wei   = init_wetteinsatz_ether*1000000000000000000;
                        
                        } //// Konstruktor

   
/* -------------------------------------------------------------------

Destruktor - Dieser Contract kann nur vom Erzeuger und wenn das 
             Spiel nicht gerade laeuft, zerstoert werden.

------------------------------------------------------------------- */
function kill() {                 
                if (
                   (msg.sender == owner) && (wette_laeuft_gerade == 0)
                   ) selfdestruct(owner); 
                } //// function kill()  
   



/* -------------------------------------------------------------------

Random - Funktion

------------------------------------------------------------------- */
function rand(uint max) returns (uint)
         {
         uint randval = uint(block.blockhash(block.number-1))%max;    
         return randval;
         }



 
/* ---------------------------

Einsatz_machen

--------------------------- */
function Einsatz_machen ( string spielername ) payable returns (bool) 
         {
         address spieler_address  = msg.sender;
         uint256 spieler_guthaben = uint256( msg.value );
         bytes memory _spielername = bytes(spielername);
         
         /*  Einzahlung zu wenig? */
         if ( spieler_guthaben < wetteinsatz_wei ) 
            {
            return false;
            }
            
         /* Kugel rollt noch... */ 
         if (wette_laeuft_gerade == 1)
            {
            return false;
            }

         /* Wenn die Wette bereits abgelaufen ist */            
         if (status >= 3)   
            {
            return false;
            }
                      
       
         /*  Spielername angegeben, min 3 Zeichen */
         if ( _spielername.length < 3) return false;
         
         
         /* Alles OK - jetzt den Spieler hinzufuegen */
         Spieler.push( Spielerstruct(spieler_address,spielername, spieler_guthaben));
         counter_spieler++;
         gewinnsumme = gewinnsumme + spieler_guthaben;
         
         
         
         /* Ab dem ersten Spieler Status Äaendern */
         if (counter_spieler < number_spieler)
            {
            status = 1;
            }

         /* Moege das Spiel nun beginnen */
         if (counter_spieler == number_spieler)
            {
            status = 2;
            wette_laeuft_gerade = 1;
            timestamp_start = now;
            }

  return true;
  } //// Einsatz_machen




/* -------------------------------------------------------------------

 Wette_Mainfunction()

------------------------------------------------------------------- */
function Wette_Mainfunction()
{

   
if (wette_laeuft_gerade == 1)
   {
   uint differenz = now - timestamp_start;
   uint gewinner_index;

   verbleibende_sekunden = int(dauer_in_sekunden) - int(differenz);
 
   if (verbleibende_sekunden <= 0)
      {
      status = 3;
      
      gewinner_index = rand( uint(number_spieler) );
     
      
      address gewinner_adresse = Spieler[gewinner_index].adresse;
      debug_gewinner_adresse = gewinner_adresse;
    
      
      
      /* Gewinn auszahlen */
      if (  gewinner_adresse.send(gewinnsumme)  )
         {
         status = 4;
         } 
         else 
            { 
            return  ;
            }
         


      wette_laeuft_gerade = 0;
      }
   
  
   
   } // if (wette_laeuft_gerade == 1)


} /// function Wette_Mainfunction()



/* -------------------------------------------------------------------

getstatus - liefert Status an Beobachter des Contracts

------------------------------------------------------------------- */
function getstatus() constant returns  (string) 
         {
         if (status == 0) msgbuffer = 'Wette nicht plaziert';     
         if (status == 1) msgbuffer = 'Erster Wetteinsatz stattgefunden';
         if (status == 2) msgbuffer = 'Wette laeuft gerade...';
         if (status == 3) msgbuffer = 'Wette abgelaufen...';
         if (status == 4) msgbuffer = 'Gewinn ausgezahlt';
   
         return( msgbuffer); 
         } //// getstatus




} //// contract kopf-oder-zahl

