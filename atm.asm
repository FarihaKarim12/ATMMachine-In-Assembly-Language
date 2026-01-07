INCLUDE Irvine32.inc

.data
user1 BYTE "Anna",0
user2 BYTE "Ruby",0
user3 BYTE "Sara",0
userName BYTE 20 DUP(0)

accPIN DWORD ?
currentUser DWORD ?
attempts DWORD 3
choice DWORD ?
inputAmount DWORD ?

pins DWORD 1111,2222,3333
balances DWORD 1000,1500,2000

inputnumber BYTE 20 DUP(0)

msgUserName BYTE "Enter username: ",0
msgAccPin BYTE "Enter PIN: ",0
msgIncorrect BYTE "Incorrect username or password. Try again.",0
msgAccessDenied BYTE "Too many attempts! Access denied.",0
msgWelcome BYTE "Login successful!",0
msgMenu1 BYTE "1. Balance Inquiry",0
msgMenu2 BYTE "2. Withdraw",0
msgMenu3 BYTE "3. Deposit",0
msgMenu4 BYTE "4. Exit",0
msgBalance BYTE "Your current balance is: ",0
msgWithdraw BYTE "Enter amount to withdraw: ",0
msgWithdrawSuccess BYTE "Withdrawal successful!",0
msgWithdrawFail BYTE "Insufficient balance!",0
msgDeposit BYTE "Enter amount to deposit: ",0
msgDepositSuccess BYTE "Deposit successful!",0
msgAmountDeposited BYTE "Amount deposited: ",0
msgInvalidInput BYTE "Invalid input! Please enter a number.",0
msgThankYou BYTE "Thank you for using Mini ATM!",0
msgChoicePrompt BYTE "Enter the number: ",0
msgAmountWithdrawn BYTE "Amount withdrawn: ",0
msgPressKey BYTE "Press any key to continue...",0
msgInvalidChoice BYTE "Invalid choice! Please enter 1-4.",0


.code

MyWaitMsg PROC
    call CrLf
    mov edx, OFFSET msgPressKey
    call WriteString
    call ReadChar       
    ret
MyWaitMsg ENDP

NameCheck PROC
push ebx
push ecx
mov ecx,20
CompareLoop: mov al,[edx]
mov bl,[esi]
cmp al,bl
jne NotEqual
cmp al,0
je Equal
inc edx
inc esi
dec ecx
jnz CompareLoop
NotEqual:mov eax,1
pop ecx
pop ebx
ret
Equal:mov eax,0
pop ecx
pop ebx
ret
NameCheck ENDP

PrintBalance PROC
push eax
call CrLf
mov edx,OFFSET msgBalance
call WriteString
pop eax
call WriteInt
call CrLf
ret
PrintBalance ENDP

Balance PROC
mov ecx, currentUser       
mov eax, balances[ecx*4] 
push eax
call PrintBalance
pop eax
call MyWaitMsg
ret
Balance ENDP

Deposit PROC
call Clrscr

DepositAmount:
mov edx,OFFSET msgDeposit
call WriteString
call ReadInt

cmp eax,0
jle InvalidAmount
mov inputAmount,eax

mov ecx, currentUser
mov eax, balances[ecx*4]    
add eax, inputAmount
mov balances[ecx*4], eax   

mov edx,OFFSET msgDepositSuccess
call WriteString
call CrLf

mov edx, OFFSET msgAmountDeposited
call WriteString
mov eax, inputAmount
call WriteInt
call CrLf

mov edx, OFFSET msgBalance           
call WriteString
mov eax, balances[ecx*4]
call WriteInt
call CrLf

call MyWaitMsg
ret

InvalidAmount:
mov edx,offset msgInvalidInput
call WriteString
call crlf
jmp DepositAmount
Deposit ENDP

Withdraw PROC
call Clrscr
getamount:
mov edx, OFFSET msgWithdraw
call WriteString
call ReadInt
cmp eax,0
jle InvalidInput
mov inputAmount, eax              

mov ecx, currentUser
mov eax, balances[ecx*4]         

cmp inputAmount, eax
ja WithdrawFail                   

sub eax, inputAmount              
mov balances[ecx*4], eax         

mov edx, OFFSET msgWithdrawSuccess
call WriteString
call CrLf

mov edx, OFFSET msgAmountWithdrawn
call WriteString
mov eax, inputAmount
call WriteInt
call CrLf

mov edx, OFFSET msgBalance
call WriteString
mov eax, balances[ecx*4]         
call WriteInt
call CrLf

call MyWaitMsg
ret

InvalidInput:
mov edx,offset msgInvalidInput
call WriteString
call Crlf
jmp getamount

WithdrawFail:
mov edx, OFFSET msgWithdrawFail
call WriteString
call CrLf
call MyWaitMsg
ret
Withdraw ENDP


PrintMenu PROC
mov edx,OFFSET msgMenu1
call WriteString
call CrLf
mov edx,OFFSET msgMenu2
call WriteString
call CrLf
mov edx,OFFSET msgMenu3
call WriteString
call CrLf
mov edx,OFFSET msgMenu4
call WriteString
call CrLf
ret
PrintMenu ENDP

ExitATM PROC
call Clrscr
mov edx,OFFSET msgThankYou
call WriteString
call CrLf
exit
ExitATM ENDP

ATMMenu PROC
MenuLoop:
call Clrscr
call PrintMenu
mov edx,OFFSET msgChoicePrompt
call WriteString
call ReadInt
mov choice,eax
cmp choice,1
je DoBalance
cmp choice,2
je DoWithdraw
cmp choice,3
je DoDeposit
cmp choice,4
je DoExit

mov edx, OFFSET msgInvalidChoice
call WriteString
call CrLf
call MyWaitMsg
jmp MenuLoop

DoBalance:
call Balance
jmp MenuLoop

DoWithdraw:
call Withdraw
jmp MenuLoop

DoDeposit:
call Deposit
jmp MenuLoop

DoExit:
call ExitATM
ret

ATMMenu ENDP

main PROC

mov attempts,3
login_loop:
login_prompt:
mov edx,OFFSET msgUserName
call WriteString
mov edx,OFFSET userName
mov ecx,LENGTHOF userName - 1
call ReadString
mov byte ptr [edx + eax],0
mov edx,OFFSET msgAccPin
call WriteString
call ReadInt
mov accPIN,eax
mov eax, 2000       
call Delay
mov edx,OFFSET user1
mov esi,OFFSET userName
call NameCheck
cmp eax,0
je check_pin_user1

mov edx,OFFSET user2
mov esi,OFFSET userName
call NameCheck
cmp eax,0
je check_pin_user2

mov edx,OFFSET user3
mov esi,OFFSET userName
call NameCheck
cmp eax,0
je check_pin_user3

dec attempts
cmp attempts,0
je access_denied
mov edx,OFFSET msgIncorrect
call WriteString
call CrLf

jmp login_prompt

check_pin_user1:
mov eax,accPIN
cmp eax,pins[0]
jne incorrect_input_after_name
mov currentUser,0
jmp login_success

check_pin_user2:
mov eax,accPIN
cmp eax,pins[4]
jne incorrect_input_after_name
mov currentUser,1
jmp login_success

check_pin_user3:
mov eax,accPIN
cmp eax,pins[8]
jne incorrect_input_after_name
mov currentUser,2
jmp login_success

incorrect_input_after_name:
dec attempts
cmp attempts,0
je access_denied
mov edx,OFFSET msgIncorrect
call WriteString
call CrLf
jmp login_prompt

access_denied:
call Clrscr
mov edx,OFFSET msgAccessDenied
call WriteString
call CrLf
exit

login_success:
call Clrscr
mov edx,OFFSET msgWelcome
call WriteString
call CrLf
 
call ATMMenu
exit
main ENDP
END main