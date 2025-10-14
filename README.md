# Github Fetcher

If you want to see a version in Portuguese (pt-br), check the [README in portuguese](./README.pt-br.md).

## Running Locally

This application uses:

- PostgreSQL

To install dependencies:

```
bundle install
```

To create the database:
```
rake db:create
```

To run migrations:
```
rake db:migrate
```

You need to set an environment variable:
Create an account at `app.bitly.com`. Generate an API KEY.
Set `BITLY_API_TOKEN` in a `.env.local` file at the project root and define the attributes. Also create a `.env.test` and set the same for testing.
Also, it may be necessary to set the database username (DB_USERNAME=your_db_username) and password (DB_PASSWORD=your_db_password)

Run `rails s` and access `localhost:3000` to start the project.

This project uses rspec. To run the tests, execute:

```
rspec spec
```

To check test coverage, run `open coverage/index.html`

## Notes

- Initially, I intended to use `mechanize` in the webscraper to fetch data. However, to get contribution data, it was not possible because the profile page loads this information via AJAX. So I used `ferrum`, which doing some research uses less memory and awaits for Javascript to run. To allow faster specs, I used `puffing-billy` to cache requests, since VCR would not work for these headless browser requests.
- I couldn't find the number of stars on the profile.
- I decided to convert abbreviated numbers to integers, in case the data is used for statistics in the future. (Ex: 10.1k - 10100)
- The service that fetches profile data is [FetchGithubProfile](./app/services/fetch_github_profile.rb). I chose to call the service directly in the controller since this is a test. Ideally, in production, the service call should be executed in an asynchronous Job, using sidekiq for example, and use push notifications to redirect the user to the created profile page with a success or failure notification. Other solution would be configure a max timeout to fetch data.
- For URL shortening, I used the Bitly API. The relevant service is [this one](./app/services/shorten_url.rb)
- I chose to organize services into separate classes to facilitate maintenance and testing.
- I implemented error handling in the services to ensure that failures in integration with external APIs do not break the main application flow.
- I used environment variables to store sensitive data, following security best practices.
- I prioritized writing automated tests to ensure the reliability of key features.
- I kept the code as simple as possible, focusing on clarity and readability.
