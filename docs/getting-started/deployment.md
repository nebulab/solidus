# Deploying to production

## Deploying to the cloud

Deploying a Solidus application to production is not different from deploying any other Rails application. In this section, we'll cover some popular options for deploying Solidus and a few additional caveats.

### Heroku

Deploying a Solidus store to [Heroku](https://heroku.com) is extremely simple. All you'll need is an active Heroku account and the [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli) on your machine.

Once you have those, you should first create a new app:

```bash
$ heroku create amazing-store
```

Now, push the code to your Heroku remote:

```bash
$ git push heroku master
```

Finally, set up the database schema and seeds:

```bash
$ heroku run rails db:schema:load db:seed
```

You're all set! Your Solidus store should now be running on Heroku.

### AWS OpsWorks

{% hint style="info" %}
This section still needs to be written.
{% endhint %}

### Kubernetes

{% hint style="info" %}
This section still needs to be written.
{% endhint %}

## External dependencies

When deploying a Solidus store, there are a few external dependencies you will also need to install, or may decide to install in order to make your application more resilient and easier to scale.

### File storage

{% hint style="warning" %}
Paperclip [has been deprecated](https://github.com/thoughtbot/paperclip#deprecated) in favor of Rails' native [ActiveStorage](https://guides.rubyonrails.org/active_storage_overview.html) library. Solidus already supports ActiveStorage but, due to limitations in ActiveStorage itself, you will not be able to use it until Rails 6.1 is released with support for [public URLs](https://edgeguides.rubyonrails.org/active_storage_overview.html#public-access).
{% endhint %}

When you run Solidus locally or on a single node, any files you upload \(product images, taxon icons etc.\) are stored on the filesystem. While this works great in development, it's not a viable option when deploying to cloud platforms, where clustering would cause files in one node not to be accessible by all other nodes, or files to disappear when a node reboots because of [ephemeral filesystems](https://devcenter.heroku.com/articles/dynos#ephemeral-filesystem).

When running your store in production, you will have to rely on a file storage service such as [Amazon S3](https://aws.amazon.com/it/s3/) or [Microsoft Azure Storage Service](https://azure.microsoft.com/en-us/services/storage/). Files will be uploaded to the storage service, which will also handle all concerns of high availability, security and distribution, and retrieved via a public URL.

Solidus supports storage services out of the box by integrating with the [Paperclip](https://github.com/thoughtbot/paperclip) gem. In order to configure Paperclip, just create an initializer like the following:

```ruby
if Rails.env.production?
  Paperclip::Attachment.default_options.merge!(
    storage: :s3,
    bucket: ENV.fetch('S3_BUCKET'),
    s3_host_name: ENV.fetch('S3_HOST_NAME'),
    s3_credentials: {
      access_key_id: ENV.fetch('S3_ACCESS_KEY_ID'),
      secret_access_key: ENV.fetch('S3_SECRET_ACCESS_KEY'),
      s3_region: ENV.fetch('S3_REGION'),
    }
  )
end
```

Finally, put your S3 credentials in the environment variables used in the initializer.

If you're not using S3, Paperclip provides support for the most popular storage services, either natively or through third-party plugins.

### Cache store

Solidus employs [fragment caching](https://guides.rubyonrails.org/caching_with_rails.html#fragment-caching) and [low-level caching](https://guides.rubyonrails.org/caching_with_rails.html#low-level-caching) pretty extensively throughout the storefront and API views. By default, Rails uses an in-memory cache adapter in production, which will essentially make all caching useless, since the cache is not shared across nodes of your application.

Instead of the default adapter, you should instead rely on an actual caching system. Popular options in the Rails ecosystem are [memcached](https://memcached.org/) and [Redis](https://redis.io/).

The procedure for configuring your cache store with Solidus is not different from doing it in a regular Rails application, so simply refer to the [Rails caching guide](https://guides.rubyonrails.org/caching_with_rails.html#activesupport-cache-memcachestore) for more details and recommendations on how to properly set up your caching server.

### Async operations

Solidus schedules certain time-intensive operations in the background, to provide faster feedback to the user and avoid blocking the Web process for too long. The most common examples are transactional emails: when an email needs to be delivered to the user, Solidus will enqueue the operation rather than executing it immediately. This operation will then be run in the background by [ActiveJob](https://guides.rubyonrails.org/active_job_basics.html).

The default ActiveJob adapter is [Async](https://api.rubyonrails.org/classes/ActiveJob/QueueAdapters/AsyncAdapter.html), which uses an in-process thread pool to schedule jobs. While a good choice for local development and testing, this is a pretty poor option for production deployments, because any pending jobs are dropped when the process restarts \([Heroku restarts dynos automatically every 24 hours](https://devcenter.heroku.com/articles/dynos#automatic-dyno-restarts), for instance\).

Instead, you should use a production-grade queue such as [Sidekiq](https://github.com/mperham/sidekiq), which uses Redis for storing and retrieving the jobs under the hood. Using Sidekiq with ActiveJob is pretty simple. First of all, install Sidekiq by adding it to your `Gemfile`:

{% code title="Gemfile" %}
```ruby
# ...
gem 'sidekiq'
```
{% endcode %}

Now install the bundle:

```bash
$ bundle install
```

Finally, tell ActiveJob to use Sidekiq for queueing and running jobs:

{% code title="config/application.rb" %}
```ruby
module YourApp
  class Application < Rails::Application
    # ...
    config.active_job.queue_adapter = :sidekiq
  end
end
```
{% endcode %}

That's it! Solidus will now use Sidekiq and Redis for all asynchronous processing. You may refer to the [Sidekiq documentation](https://github.com/mperham/sidekiq) and [ActiveJob documentation](https://guides.rubyonrails.org/active_job_basics.html) for advanced configuration.

### Content delivery network

It is strongly recommended to serve static assets via a [Content Delivery Network \(CDN\)](https://it.wikipedia.org/wiki/Content_Delivery_Network) rather than your own application. CDNs are a relatively simple and efficient way to instantaneously boost the performance of your application and are widely used in Web development.

Like for many other tasks, configuring a CDN for Solidus is the same as configuring it for a regular Rails application, so you can refer to the Rails guides on [configuring a CDN](https://guides.rubyonrails.org/asset_pipeline.html#cdns).

There are many reliable CDNs, with the most popular being [Amazon CloudFront](https://aws.amazon.com/it/cloudfront/).

### Email delivery

In order to send emails, Solidus needs a valid SMTP server. While you could use your domain registrar's mail server, it is usually recommended to use a more robust and feature-complete solution that will also provide useful insights and business metrics such as your deliverability, open and click-through rates.

[SendGrid](https://sendgrid.com/), [Mailgun](https://www.mailgun.com/) and [Mailchimp](https://mailchimp.com/features/transactional-email/) are all very good, battle-tested solutions for delivering transactional emails to your customers, but you are free to use any other service you wish.

Most of these services provide a regular SMTP server you can use to deliver emails, which you can configure in Rails. Here's an example configuration for SendGrid:

{% code title="config/application.rb" %}
```ruby
module YourApp
  class Application < Rails::Application
    # ...
    config.action_mailer.smtp_settings = {
      user_name: ENV.fetch('SENDGRID_USERNAME'),
      password: ENV.fetch('SENDGRID_PASSWORD'),
      domain: ENV.fetch('SENDGRID_DOMAIN'),
      address: 'smtp.sendgrid.net',
      port: 465,
      authentication: :plain,
      enable_starttls_auto: true,
    }
  end
end
```
{% endcode %}

You should then configure the `SENDGRID_USERNAME`, `SENDGRID_PASSWORD` and `SENDGRID_DOMAIN` environment variables with your SendGrid credentials.

