# Credit Card API APP

## How to use

```
https://palomar-creditcardapi.herokuapp.com/api/v1/credit_card/validate?card_number=4916603231464963
```
Where the number sequence at the end represnt the Credit Card Number, in this case, the number is a valid number.

While the example below is an invalid number.
```
https://palomar-creditcardapi.herokuapp.com/api/v1/credit_card/validate?card_number=4024097178888052
```

Depending on whether the number is invalid or valid the App returns a string like
```{"Card":"4024097178888052","validated": "true/false"} ```

## [Heroku Location](https://palomar-creditcardapi.herokuapp.com/)
