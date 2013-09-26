---
layout: post
title: Scribble, a Jekyll theme
date: 2013-05-06 16:27:31
disqus: y
---

I have other themes, checkout (mainly) [this repository](https://github.com/muan/muan.github.com/releases) and [this repository](https://github.com/muan/jekyll-wardrobe). <3

---

There is no clever design philosophy to talk about, I tried to find something to work with, and 'scribble' came to my mind. This theme uses Open Sans powered by Google Web Fonts, and was written in plain HTML, SCSS & CoffeeScript, though .scss & .coffee files wouldn't be included in the theme. 

The theme is mobile optimised but I did not check browser compatibility. It looks great in Chrome, Safari and Firefox though.

<a href="https://github.com/muan/scribble" target="_blank" class="big-button gray">Get it on GitHub &hearts;</a>

---

### Get started

1. [Fork the repository](https://github.com/muan/scribble/fork).
2. Clone the repository to your computer.<br /> `git clone https://github.com/username/scribble`
3. `bundle install`
4. **If using older versions of Jekyll**<br />
  Build and run jekyll using `jekyll --server --auto`.<br />
  **If using [Jekyll 1.0](http://blog.parkermoore.de/2013/05/06/jekyll-1-dot-0-released/)**<br />
  Build Jekyll using `jekyll build`.<br />
  Then run Jekyll using `jekyll serve --watch`<br />
5. Go to http://localhost:4000 for your site.

---

### Make it yours

1. I have extract most user specific information to `_config.yml`, you should be able to set up almost everything from it.
2. Change about.md for blog intro.
3. For domain settings, see [the guide from GitHub](https://help.github.com/articles/setting-up-a-custom-domain-with-pages).

---

### Options

When writing a post, there are 3 options you can add to the header.

1. **disqus: y**<br />
  If disqus is set to 'y', at the end of the post there will be a disqus thread, just like this one. To use disqus, you MUST [set up your own disqus account](http://disqus.com/).

2. **share: y**<br />
  An option for showing tweet and like button under a post.

3. **date**: 2013-05-06 18:07:17<br />
  Date is not a required header since Jekyll reads the file name for date, this was added in only for the **signoff time**. (as shown at the end of this post) If you don't want the signoff time, go into `/includes/signoff.html` and remove the `<span>`.

---

<a href="https://github.com/muan/scribble" target="_blank" class="big-button gray">Get it on GitHub &hearts;</a>

---

### The end

Like it? [Tell me](http://twitter.com/muanchiou).<br/>
Problem? [Use GitHub Issues](https://github.com/muan/scribble).