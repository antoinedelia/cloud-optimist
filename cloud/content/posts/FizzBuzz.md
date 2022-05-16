---
title: "FizzBuzz, the simplest, more efficient way to test a developer"
date: 2022-05-16T22:49:13+02:00
draft: false
---

When I got out of my engineering school, I passed a lot of interviews in the hope of getting a developer job. My experiences being limited to having done a few internships, I was fearing the part of the interview where I would have had to get up and resolve some complex algorithm exercice on a white board, or even just answer a few technical questions. I was wrong.

**Not a single interview tested me on my development skills.**

I could've lied my way through the whole interview that I would still have gotten the job.

To be honest, I'm not part of the people who praise technical questions like it is some kind of magic spell to detect good programmers. I'd rather think than someone with a good temperament, passionate and humanely pleasant is much more appreciated than a know-it-all who always brings his science to the table without wanting to hear anyone else opinions. <strong>You can improve a technical gap, but you can't improve a shitty character.</strong>

I do believe however that it is mandatory to at least check the way of thinking of someone when being confronted to a problem. Because in the end, that's what he is gonna do most of his job: resolve problems. As such, it is crucial to see how someone will behave when being presented a problem. Will he run away? Will he immediately ask for help?

That's when the <strong>FizzBuzz</strong> test comes into play.

> This post was inspired by [Tom Scott's video](https://www.youtube.com/watch?v=QPZ0pIK_wsc) that I strongly suggest you to have a look at if this topic interests you.

The idea behind FizzBuzz is straight-forward. You need to count out loud numbers starting at 1 until you reach 100. But, if the number is a multiple of 3, you have to say the word "Fizz" instead. In the same way, if the number is a multiple of 5, you have to say the word "Buzz". Now you might be thinking: "Then what am I supposed to do when it is a multiple of both 3 and 5?". Well, you would simply have to say "FizzBuzz". <em>Roll credits</em>.

By reading this simple test, you might wonder why this should be used, as it appears that even an intern could solve it quite easily. Well, that's what I thought too, until I ran accros [Jeff Atwood's post on this subject](https://blog.codinghorror.com/why-cant-programmers-program/), stating that he was surprised how this problem actually gave a lot of troubles to candidates, even senior ones.

<strong>So let's try to solve it together!</strong>

<em>In most technical interviews and as such for this exercice, you are free to use any programming language you feel most confortable with, or even write using [pseudocode](https://en.wikipedia.org/wiki/Pseudocode). For this post, I'm gonna use Python.</em>

First things first, let's create a simple loop that prints all numbers from 1 to 100.

```python
for i in range(1, 101):
    print(i)
```

Off to a great start! Now let's review the original statement: if the number is a multiple of 3, show "Fizz", if the number is a multiple of 5, show "Buzz". No Let's add these conditions.

```python
for i in range(1, 101):
    if i % 3 == 0:
        print('Fizz')
    if i % 5 == 0:
        print('Buzz')
    if i % 3 != 0 and i % 5 != 0:
        print(i)
```

Let's take a minute to see what we did here. <strong>In order to check whether a number is a multiple of 3, we are using the modulo with the symbol %.</strong>We are doing the same thing for multiples of 5. Finally, if the number is neither a multiple of 3 nor 5, we simply display it.

This way we get exactly what we want !... Except when a number is a multiple of both 3 and 5. When that happens, <strong>the words Fizz and Buzz are not displayed on the same line !</strong> We shall then take into account this case by adding a new condition, and prevent the first two `if` to trigger.

```python
for i in range(1, 101):
    if i % 3 == 0 and i % 5 != 0:
        print('Fizz')
    if i % 5 == 0 and i % 3 != 0:
        print('Buzz')
    if i % 3 == 0 and i % 5 == 0:
        print('FizzBuzz')
    if i % 3 != 0 and i % 5 != 0:
        print(i)
```

This finally works! But at what cost? <strong>This whole code is a mess.</strong> And it is by no means a piece of code that can easily be maintained. Take this issue as an example: what would happen if we now want to display the word Fizz for multiples of 2 instead of 3? <strong>We will have to change this value at 4 different places through the code</strong> to make it work.

This might look trivial with such a minimalistic code, but imagine what would happen if this happened on a much bigger project. <strong>This code is prone to errors, complicates its maintainability and makes it almost impossible to add new features easily.</strong>

Let's try another approach to make this code more elegant! We'll first declare a variable which will be the value we want to print at the end. We'll make it an empty string for now. Each time we successfully match a condition, we'll simply append the corresponding word to the result. At the end, checking if the variable is empty will let us know if we should print it or rather print the number. 

This is what we get.

```python
for i in range(1, 101):
    result = ''
    if i % 3 == 0:
        result += 'Fizz'
    if i % 5 == 0:
        result += 'Buzz'
    print(result or i)
```

It's already much clearer! Not only did we shrink the number of lines by half, our `if` checks are now cristal clear and don't let any rooms for misinterpretation. Plus, we can easily change the value of any of the numbers if we need to without having to look for all its occurrences. Last but not least, if we ever need to add yet another condition for multiples of 7, we'll simply have to add two new lines without changing the rest of the code!

We can finally see how this simple FizzBuzz test is so interesting. We were able to test one's ability to use simple algorithmic principles, but also to check his way of thinking when being confronted to a problem, and if he is able to produce a code that takes care of its future.

<strong>To make it short, FizzBuzz is a good way to differentiate a developer from a good developer.</strong>