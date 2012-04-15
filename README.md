# PHP Refactoring Browser for Vim

*phprefactor* is a tiny refactoring browser for PHP. It runs on the powerful editor **Vim**.

Installation
------------

If you have already installed [pathogen](https://github.com/tpope/vim-pathogen), input following commands.

```
$cd ~/.vim/bundle
$git clone https://github.com/potix2/vim-phprefactor
```

Usage
-----

### Rename Local Variable

![](http://potix2.github.com/images/vim-phprefactor/screen1.png)

Change the cursor position to a local variable.

![](http://potix2.github.com/images/vim-phprefactor/screen2.png)

Type ```<Leader>rr``` (```<Leader>``` is mapped '\' if you didn't change the default leader setting.)

And input a new variable name and press enter.

### Introduce Local Variable

Select an expression you want to extract as a local variable in visual mode, then type ```<Leader>rv```.

And input a name for the extracted variable.

Defaut key mappings
-------------------

```
<Leader>rr  - Rename Local Variable  (normal mode)
<Leader>rv  - Introduce Local Variable  (visual mode)
```

License
-------

MIT License

Author
------

Katsunori Kanda <potix2@gmail.com>
