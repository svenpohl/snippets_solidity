/*
 
Timesafe.sol - sven@derkryptonaer.de
 
26.Okt.2017 - Version 1.0 - erstellt
 
*/
pragma solidity ^0.4.18;
 
contract timesafe
{
address public owner;
uint256 public timestamp_payout = 0;
uint256 public sekunden_bis_zur_auszahlung = 0;
string public meldung;
 
//
//
// Konstruktor
//
//
function timesafe ( uint _timestamp_payout ) public
{
owner = msg.sender;
timestamp_payout = _timestamp_payout;
} // function timesafe
 
//
//
// Einzahlung
//
//
function () payable public
{
meldung = "Einzahlung wurde gemacht!";
} // ()
 
//
//
// withdraw - Auszahlung
//
//
function withdraw () public
{
 
if ( (msg.sender == owner) )
{
 
if (now >= timestamp_payout)
{
//
// Auszahlung
//
owner.transfer( this.balance );
 
selfdestruct(owner);
meldung = "OK!";
} else
{
sekunden_bis_zur_auszahlung = timestamp_payout - now;
meldung = "Zeit noch nicht abgelaufen!";
}
 
} // if ( (msg.sender == owner) )
else
{
meldung = "Falsche Adresse!";
}
 
} // function withdraw ()
 
} // END - contract timesafe