<html><body>
<?php
/*

send_erc20_token_example.php 

- Example script to send my ERC20-Token via PHP programmatically. 
  Wallet: Parity.

V1.0 - 29.oct.2017 created by sven@derkryptonaer.de - https://github.com/svenpohl

Prepare Parity:
1) Start parity from shell with personal-api support (important!)
$ ./parity --chain=kovan  --jsonrpc-apis web3,eth,net,parity,traces,rpc,personal

2) Open a SECOND shell
$ geth attach http://localhost:8545                                
                      
3) In this shell, UNLOCK your sender-account
> personal.unlockAccount('0x00B83F32eA95572BEc7d04674F50c754470Eca8d', 'your-password')                      
                                                                                    
*/

printf("Example for sending ERC20 token programmatically with PHP.<br>");
printf("<br>");

//
// Configuration:
//
$rpc_port             =  8545;        // parity
$rpc_host             = "127.0.0.1"; // localhost
$sender_account       = "0x00B83F32eAf5e72BEc7c04646F55c754470Eca8d";
$erc20_token_contract = "0x2dED86cDA10fCd20125E59b3502B7eDf81CD3C67";

//
// Curl function for json-rpc requests
//
function do_call($host, $port, $request) 
{  
$url = "http://$host:$port/";
$header[] = "Content-type: application/json";     
$header[] = "Content-length: ".strlen($request);
    
$ch = curl_init();   
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
curl_setopt($ch, CURLOPT_TIMEOUT, 1);
curl_setopt($ch, CURLOPT_HTTPHEADER, $header);
curl_setopt($ch, CURLOPT_POSTFIELDS, $request);
    
$data = curl_exec($ch);       

if (curl_errno($ch)) 
   {
   print curl_error($ch);
   } else {
          curl_close($ch);
          return $data;
          }
    
curl_close($ch);
} // do_call


//
// Convert hex to string.
//
function hex2str($hex) {
    $str = '';
    for($i=0;$i<strlen($hex);$i+=2) $str .= chr(hexdec(substr($hex,$i,2)));
    return $str;
}


//
//
// Example 1 - Get current block Number
//
//
if (1)
{
$request = '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}';  
$response = do_call($rpc_host, $rpc_port, $request);
$response_encoded = json_decode($response,true);


if ( isset($response_encoded['error']) ) 
   {
   $error = $response_encoded['error'];
   print("Error! <pre>" . print_r($error,true) . "</pre><br>");
   return 0;
   } else
     {
     $result_value = hexdec( $response_encoded['result'] );
     print("Current block number: $result_value<br>" );
     
     print("<pre>");
     print_r($response_encoded);
     print("</pre>");
     }
               
exit(0);
} // if (1) ----------------------------------------------




//
//
// Example 2 - Get balance of an account
//
//
if (0)
{

$request = '{"jsonrpc":"2.0","method":"eth_getBalance","params":["'.$sender_account.'4"],"id":1}'; 
$response = do_call($rpc_host, $rpc_port, $request);
$response_encoded = json_decode($response,true);

if ( isset($response_encoded['error']) ) 
   {
   $error = $response_encoded['error'];
   print("Error! <pre>" . print_r($error,true) . "</pre><br>");
   return 0;
   } else
     {
     $result_value = hexdec( $response_encoded['result'] );
     $result_value = $result_value / 1000000000000000000;
     print("Balance (ETH): $result_value<br>" );
     
     print("<pre>");
     print_r($response_encoded);
     print("</pre>");
     }
               
exit(0);
} // if (1) ----------------------------------------------





//
//
// Example 2 - Send  ERC20-token of an account
//
//
if (0)
{

/* ---
Data-block in details:

1) Hash of Function 
web3.sha3("transfer(address,uint256)")
0xa9059cbb2ab09eb219583 <- 
0011223344

0xa9059cbb <- first bytes of $data

2) Address of payee 0x00BF97256946CF0CA5278a3dab0648F651B584F9
00000000000000000000000000BF97256946CF0CA5278a3dab0648F651B584F9 <- fill with zeros to 32 bytes.

3) Amount in wei
If you want to send 1000 Tokens (Contract configuration: decimals = 18) you get:
1000000000000000000000 -> toHEX -> 3635c9adc5dea00000
00000000000000000000000000000000000000000000003635c9adc5dea00000 <- fill with zeros to 32 bytes.

--- */

$data = "0xa9059cbb00000000000000000000000000BF97256946CF0CA5278a3dab0648F651B584F900000000000000000000000000000000000000000000003635c9adc5dea00000"; 
$request = '{"jsonrpc":"2.0","method":"eth_sendTransaction","params":[{"from": "'.$sender_account.'", "to": "'.$erc20_token_contract.'", "data": "'.$data.'"}],"id":1}'; 

//printf("request:<br>".$request."<br><br>");
 

$response = do_call($rpc_host, $rpc_port, $request);
$response_encoded = json_decode($response,true);

if ( isset($response_encoded['error']) ) 
   {
   $error = $response_encoded['error'];
   print("Error!: " . $error . "<br>");
   return 0;
   } else
     {
     print("<pre>");
     print_r($response_encoded);
     print("</pre>");
     }
            
/*
If success you see somethink like this, where [result] contains the transaction-ID:

Array
(
    [jsonrpc] => 2.0
    [result] => 0x85201e70b20079fa1504e751e2187799abaa954648ada467241dcda95dd5792e
    [id] => 1
)

*/            
               
exit(0);
} // if (1) ----------------------------------------------



?>
</body></html>