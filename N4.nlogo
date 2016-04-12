globals [
  bank-loans
  bank-ReservesCoefficient
  bank-deposits
  bank-to-loan
  xmax
  ymax
  rich
  poor
  bankrupt
  middle-class
  income-max
]

turtles-own [
  savings
  loans
  wallet
  temp-loan
  wealth
  customer
  bankruptcy?
  opportunities
]

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;                     ;;;
;;;  Setup Procedures   ;;;
;;;                     ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;


to setup
  clear-all
  initialize-settings
  create-turtles people [setup-turtles]
  poll-class
  setup-bank
  set xmax 300
  set ymax (2 * money-total)
  reset-ticks
end


to initialize-settings
  set rich 0
  set poor 0
  set middle-class 0
  set bankrupt 0
  set income-max 10
end

to setup-turtles  ;;Turtle Procedure
  set shape "person"
  setxy random-xcor random-ycor
  set wallet (random 2 * income-max)
  set savings 0
  set loans 0
  set wealth 0
  set customer -1
  set bankruptcy? false
  set opportunities 200 ;time to return a loan before bankruptcy
  get-color
end

to setup-bank
  set bank-loans 0
  set bank-ReservesCoefficient 0
  set bank-deposits 0
  set bank-to-loan 0
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;                     ;;;
;;; Run Time Procedures ;;;
;;;                     ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go
  ;ask turtles [do-business]
  ask turtles [
    if (bankruptcy? = false)
    [
      do-business
      balance-books
      get-color
    ]
  ]
  bank-balance-sheet
  poll-class
  if (SystemRelief = true and bankrupt > 5) ;bankrupt percentage > 45%
  [
    ask turtles
    [
    relief
    ]
  ]
  tick
end

;; polls the number in each corresponding economic class
to poll-class
  set bankrupt (count turtles with [bankruptcy? = true]) * 100 / count turtles
  set rich (count turtles with [savings > income-max] + (0.1 * bankrupt)) * 100 / count turtles
  set poor ((count turtles with [loans > income-max]) + bankrupt) * 100 / count turtles
  set middle-class (100 - (rich + poor + bankrupt))
end

to do-business  ;;Turtle Procedure
  rt random 360
  fd 1
  ;; turtle has money to trade with, and there is
  ;; another turtle to trade with on the same patch
  if ((savings > 0) or (wallet > 0) or (bank-to-loan > 0)) [
    set customer one-of other turtles-here
    if customer != nobody and (random 2) = 0          ;;50% chance of trading
      [ifelse (random 2 = 0)                          ;;50% chance of trading $2 or $5, if trading
         [ask customer [set wallet wallet + 5]
          set wallet (wallet - 5)]
         [ask customer [set wallet wallet + 2]
          set wallet (wallet - 2)]
      ]
  ]
end

;; Check the balance of our wallet.
;; Put a positive balance in savings.  Try to get a loan to cover a
;; negative balance.  If we cannot get a loan (if bank-to-loan < 0)
;; then maintain the negative wallet balance until the next round.
to balance-books  ;;Turtle Procedure
  ifelse (wallet < 0)
   [
     ifelse (savings >= (- wallet))
      [withdraw-from-savings (- wallet)]
      [
        if (savings > 0)
        [withdraw-from-savings savings
         ]

        get-a-loan (- wallet)
      ]

   ]
   [deposit-to-savings wallet]

;; repay loans if savings are available
  if (loans > 0)[  ;and (savings > 0)
    ifelse (savings >= loans)
      [withdraw-from-savings loans
       repay-a-loan loans]
      [withdraw-from-savings savings
       repay-a-loan wallet]
  ]

  ;if (loans > 0)[
  ; ifelse
  ;]

end

to get-a-loan [amount]
  set temp-loan bank-to-loan

  if (bankruptcy? = false)
    [
      ifelse (temp-loan >= amount)
      ;[
      ;ifelse(bankruptcy? = true or opportunities = 0)
      ;[set color yellow set opportunities opportunities - 1 set bankruptcy? true]
      [take-out-a-loan amount]
      ;]
         ;[
         ;ifelse(bankruptcy? = true or opportunities = 0)
         ;[set color yellow set opportunities opportunities - 1 set bankruptcy? true]
      [take-out-a-loan temp-loan]
      ;]
      set opportunities opportunities - 1
      if (opportunities = 0) [set bankruptcy? true]
    ]
end


;; Sets aside required amount from liabilities into
;; ReservesCoefficient, regardless of outstanding loans.  This may
;; result in a negative bank-to-loan amount, which
;; means that the bank will be unable to loan money
;; until it can set enough aside to account for ReservesCoefficient.
to bank-balance-sheet
  set bank-deposits sum [savings] of turtles
  set bank-loans sum [loans] of turtles
  ifelse(SystemRelief = true)
  [
   set bank-ReservesCoefficient bank-deposits
    ]
  [
    set bank-ReservesCoefficient ((ReservesCoefficient / 100) * bank-deposits)
  ]
  ifelse(SystemRelief = true)
  [
    set bank-ReservesCoefficient (bank-ReservesCoefficient / 1.1)
  ]
  [
    set bank-ReservesCoefficient (bank-ReservesCoefficient / (QE * (Expectations + 0.6))) ;if excpectations high, it multiplies QE effects
  ]
  set bank-to-loan (bank-deposits - (bank-ReservesCoefficient + bank-loans))
end


to deposit-to-savings [amount]  ;; Turtle Procedure
  set wallet (wallet - amount)
  set savings (savings + amount)
end

to withdraw-from-savings [amount]  ;; Turtle Procedure
  set wallet (wallet + amount)
  set savings (savings - amount)
end


to repay-a-loan [amount]  ;; Turtle Procedure
  set loans (loans - amount)
  set wallet (wallet - amount)
  set bank-to-loan (bank-to-loan + amount)
end

to take-out-a-loan [amount]  ;; Turtle Procedure
  set loans (loans + amount)
  set wallet (wallet + amount)
  set bank-to-loan (bank-to-loan - amount)
end


;; color codes the rich (green),
;; middle-class (gray), and poor (red)
to get-color ;;Turtle Procedure
  set color gray
  if (savings > income-max) [set color green]
  if (loans > income-max)  [set color red]
  set wealth (savings - loans)
  if (bankruptcy? = true)
  [
    set color yellow
  ]
end

to relief
  let free-help min[savings + wallet] of turtles with[savings + wallet > 0]
  set wallet wallet + free-help
  set opportunities opportunities + 70
  set bank-to-loan bank-to-loan + (count (turtles)) * free-help * 0.2
  if (bankruptcy? = true and (savings + wallet) > 0)
  [
    set bankruptcy? false
    get-color
    ]
end


to-report savings-total
  report sum [savings] of turtles
end

to-report loans-total
  report sum [loans] of turtles
end

to-report wallets-total
  report sum [wallet] of turtles
end

to-report money-total
  report sum [wallet + savings] of turtles
end


