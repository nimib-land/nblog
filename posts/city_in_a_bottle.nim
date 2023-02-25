import nimib

nbInit

nbText: """# City in a bottle
> example of usage of `nbRawHtml`

How do I embed a tweet like [this great tweet](https://twitter.com/killedbyapixel/status/1517294627996545024) in nimib?

Easy! Just go in the top right corner of the tweet (⋮), click on "Embed Tweet", copy the code
and use `nbRawHtml` (see source by clicking "Show Source" button below)
"""
nbRawHtml: """<blockquote class="twitter-tweet"><p lang="en" dir="ltr">A City in a Bottle 🌆<br><br>&lt;canvas style=width:99% id=c onclick=setInterval(&#39;for(c.width=w=99,++t,i=6e3;i--;c.getContext`2d`.fillRect(i%w,i/w|0,1-d*Z/w+s,1))for(a=i%w/50-1,s=b=1-i/4e3,X=t,Y=Z=d=1;++Z&lt;w&amp;(Y&lt;6-(32&lt;Z&amp;27&lt;X%w&amp;&amp;X/9^Z/8)*8%46||d|(s=(X&amp;Y&amp;Z)%3/Z,a=b=1,d=Z/w));Y-=b)X+=a&#39;,t=9)&gt; <a href="https://t.co/N3WElPqtMY">pic.twitter.com/N3WElPqtMY</a></p>&mdash; Frank Force 🌻 (@KilledByAPixel) <a href="https://twitter.com/KilledByAPixel/status/1517294627996545024?ref_src=twsrc%5Etfw">April 22, 2022</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>"""

nbText: "And we can use `nbRawHtml` also to visualize the canvas code. The only adjustment I made is to add a solid border. Click inside to start the animation."
nbRawHtml: """<canvas style="width:99%; border:1px solid #000000;" id=c onclick=setInterval('for(c.width=w=99,++t,i=6e3;i--;c.getContext`2d`.fillRect(i%w,i/w|0,1-d*Z/w+s,1))for(a=i%w/50-1,s=b=1-i/4e3,X=t,Y=Z=d=1;++Z<w&(Y<6-(32<Z&27<X%w&&X/9^Z/8)*8%46||d|(s=(X&Y&Z)%3/Z,a=b=1,d=Z/w));Y-=b)X+=a',t=9)></canvas>"""

nbText: """Not sure why, but after you click a big white vertical area is created.

Anyhoo, enjoy another tweet that links to a great Observable document that explains the code
(I guess that now we should be able to reproduce that observable document in nimib...):
"""
nbRawHtml: """<blockquote class="twitter-tweet"><p lang="en" dir="ltr">If you&#39;d like to learn how the code works, I recommend checking out this amazing breakdown by <a href="https://twitter.com/DanielDarabos?ref_src=twsrc%5Etfw">@DanielDarabos</a> that reorganizes and comments the code and provides controls to play with it.<a href="https://t.co/SVtC0yF0gJ">https://t.co/SVtC0yF0gJ</a></p>&mdash; Frank Force 🌻 (@KilledByAPixel) <a href="https://twitter.com/KilledByAPixel/status/1529838360235220992?ref_src=twsrc%5Etfw">May 26, 2022</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>"""

nbText: "And actually this content was inspired by the following tweet exchange that brought back in my timeline the amazing city in a bottle:"
nbRawHtml: """<blockquote class="twitter-tweet"><p lang="en" dir="ltr">It has its limits! I tried running <a href="https://twitter.com/KilledByAPixel?ref_src=twsrc%5Etfw">@KilledByAPixel</a>&#39;s amazing City in a Bottle tweet-length shader through it, and GPT-3 replied with the equivalent of a ¯\_(ツ)_/¯ <a href="https://t.co/n1c4oNEwNC">https://t.co/n1c4oNEwNC</a> <a href="https://t.co/FeYixu7JS6">pic.twitter.com/FeYixu7JS6</a></p>&mdash; Andy Baio (@waxpancake) <a href="https://twitter.com/waxpancake/status/1546634381183164416?ref_src=twsrc%5Etfw">July 11, 2022</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>"""

nbText: "Do I like Twitter? Oh, boy..."
nbRawHtml: """<blockquote class="twitter-tweet"><p lang="en" dir="ltr">Oh, boy! West Coast, <a href="https://twitter.com/hashtag/YoungSheldon?src=hash&amp;ref_src=twsrc%5Etfw">#YoungSheldon</a> starts now! <a href="https://t.co/bpSn7NySME">pic.twitter.com/bpSn7NySME</a></p>&mdash; Young Sheldon (@YoungSheldon) <a href="https://twitter.com/YoungSheldon/status/1081045053798273024?ref_src=twsrc%5Etfw">January 4, 2019</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>"""

nbSave