[![Coverage Status](https://coveralls.io/repos/github/HugoTamaki/github_fetcher/badge.svg?branch=main)](https://coveralls.io/github/HugoTamaki/github_fetcher?branch=main)

# Github Fetcher

## Para rodar em ambiente local

Essa aplicação usa:

- PostgreSQL

Para instalar as dependencias:

```
bundle install
```

Para criar o database:
```
rake db:create
```

Para rodar as migrations:
```
rake db:migrate
```

Você precisa definir uma variavel de ambiente:
Crie uma conta em `app.bitly.com`. Gere uma API KEY.
Defina `BITLY_API_TOKEN` em um arquivo `.env.local` na raiz do projeto e defina os atributos. Crie um `.env.test` e defina o mesmo para o teste também.

Execute `rails s` e acesse `localhost:3000` para rodar o projeto

Esse projeto usa rspec. Para rodar os testes, rode:

```
rspec spec
```

## Considerações

- Inicialmente pretendia usar `mechanize` no webscrapper para pegar os dados. Porém para pegar os dados de contribuições, não seria possivel pois a pagina de perfil carrega essa informação via AJAX. Usei então `selenium-webdriver`. Com o `selenium-webdriver`, não foi possível usar VCR para cachear as requests. Nesse caso usei a gem `puffing-billy`. Usei o VCR no projeto para cachear as requests do encurtador de URLs.
- Não encontrei o número de stars no perfil.
- Tomei a decisão de converter os numeros abreviados para numeros inteiros, pro caso de futuramente poder usar os dados para estatistica. (Ex: 10.1k - 10100)
- Precisei dar um tempo de 1 segundo para poder dar a chance de carregar os dados via AJAX do perfil. O service de pegar os dados do perfil é o [FetchGithubProfile](./app/services/fetch_github_profile.rb). Tomei a decisão de executar a chamada direto no controller por se tratar de um teste. Dito isso, o ideal para rodar em produção seria executar a chamada do service em um Job assincrono, usando sidekiq por exemplo, e usar push notification pra poder encaminhar o usuario pra pagina de perfil criado com uma notificação de sucesso ou falha.
- Para o encurtamento de URL, usei a API do bitly. O service em questão é [este](./app/services/shorten_url.rb)
- Optei por organizar os serviços em classes separadas para facilitar a manutenção e testes.
- Implementei tratamento de erros nos serviços para garantir que falhas na integração com APIs externas não quebrem o fluxo principal da aplicação.
- Utilizei variáveis de ambiente para armazenar dados sensíveis, seguindo boas práticas de segurança.
- Priorizei a escrita de testes automatizados para garantir a confiabilidade das principais funcionalidades.
- Mantive o código o mais simples possível, focando em clareza e legibilidade.