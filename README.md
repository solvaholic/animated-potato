# animated-potato
@solvaholic is working through _Rails Crash Course_ from No Starch Press

Work in a shell in a Docker container:

```bash
docker run -it --rm --entrypoint /bin/bash \
--volume "$(realpath .)":/code:rw \
--publish 3000:3000 \
ruby:2-buster
```

Make it ready to run Ruby on Rails and the examples in the book:

```bash
gem install rails
_nvm=https://raw.githubusercontent.com/nvm-sh/nvm/3fea5493a4/install.sh
curl -o- "${_nvm}" | bash
. ~/.bashrc
nvm install --lts
nvm use --lts
npm install --global yarn
mkdir -p ~/code
cd ~/code
rails new blog
```
