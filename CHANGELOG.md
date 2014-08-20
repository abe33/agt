<a name="0.0.1"></a>
# 0.0.1 (2014-08-20)

## :sparkles: Features

- Add gemification tasks to prepare, build and publish a gem ([5410fa41](https://github.com/abe33/agt.git/commit/5410fa411ef3ab702c0df3b11a7fc8a082acaaed))
- Add gemify task stub ([27d1a97b](https://github.com/abe33/agt.git/commit/27d1a97b81934db93fc35b14134828577dd780b1))
- Add sprite and animation classes ([1aa9040e](https://github.com/abe33/agt.git/commit/1aa9040ee77931008362a30bd23ef8bd5ad3209a))
- Add a namespace helper ([79bc9fe8](https://github.com/abe33/agt.git/commit/79bc9fe8e85b1b861f54fa7fa3da1acecfc6fb18))  <br>It initializes the namespaces and ensure that namespaces
  exists, reducing the amount of namespaces created in the index.
- Add past tense inflections ([8071b818](https://github.com/abe33/agt.git/commit/8071b8189932d17ec8bd4bb97e0ec580db1c9954))
- Add string inflections with plural/singular support ([bf5ca15c](https://github.com/abe33/agt.git/commit/bf5ca15cf1e2ff5cd4b84a278c24500606ff1766))
- Add StateMachine mixin ([14298101](https://github.com/abe33/agt.git/commit/142981016649677cbf91876d54e5e7782249ae99))
- Add tests for widgets activation ([d5929ef8](https://github.com/abe33/agt.git/commit/d5929ef86d4466b76900bc2233e34597dbb4f2e4))
- Add live reload script in spec runner ([4bce009e](https://github.com/abe33/agt.git/commit/4bce009e3547050266443d4bd294c304fd6db589))
- Add an after each hook to reset the widgets and avoid pollution ([e1193a6b](https://github.com/abe33/agt.git/commit/e1193a6b5b4045ab3541079e5ad310826ebced92))
- Add a fixture helper for browser specs ([0ad6664c](https://github.com/abe33/agt.git/commit/0ad6664c870f1644bf8aa9066556f0feaf76ddf1))
- Add a default widget instance when calling block ([3fb300f2](https://github.com/abe33/agt.git/commit/3fb300f2ae93e65f21764dd59f9e780434bcbbde))  <br>This widget instance is both activable and disposable.
  This will allow several things:
  - The block can freely defines hook for activable/disposable methods
  - Being sure that we have an instance stored in the hash that match the
  widget interface we doesn’t have to test everything when calling a
  method on it.
  - The block have a real object to store data in.
- Add watcher for package.json to trigger npm install on changes ([98e711f2](https://github.com/abe33/agt.git/commit/98e711f269199f14d0ccf42e708740fc9895d720))
- Implement a new build allowing to access individual classes ([5f48cbc7](https://github.com/abe33/agt.git/commit/5f48cbc7ac7ce188743ce47019d6ba568a02e18d))  <br>The previous generated `lib` now appears in `build`, the `lib`
  directory now host the compiled files on a 1-1 basis.
- Add some basic widgets ([d55bc7cd](https://github.com/abe33/agt.git/commit/d55bc7cd6139aa3e85fd92b375599137e43bb77d))
- Implement splats for activation/deactivation/release methods ([fe162b09](https://github.com/abe33/agt.git/commit/fe162b09b353f86ce9ff05593074e37083ad053b))
- Add widgets classes and include it in build ([fe58b3a1](https://github.com/abe33/agt.git/commit/fe58b3a1c036a0de24635004ca2dedcbd7e71110))
- Add LICENSE file ([c798b147](https://github.com/abe33/agt.git/commit/c798b147ac6e6f19b59e0d359c6a643522ae49eb))
- Add Promise and Router classes ([6852bee8](https://github.com/abe33/agt.git/commit/6852bee8310e4c809c532cc7769361bc6e481cd4))
- Add more example generator functions ([55fe65c1](https://github.com/abe33/agt.git/commit/55fe65c189f2ef0d15edbde2d3607253438192ed))
- Add demos compilation and minimap markers ([0c26e501](https://github.com/abe33/agt.git/commit/0c26e501b1272568923883c93b12d038dfe87ce4))

## :bug: Bug Fixes

- Fix route when history API isn't available ([3b1861df](https://github.com/abe33/agt.git/commit/3b1861df019279b564decc09e337e225ca1fbed7))
