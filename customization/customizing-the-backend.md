# Customizing the backend

## Designing your feature

When adding a feature to the backend UI, it's important that you spend some time designing the ideal UX for your store administrators. There are usually different ways to implement the same feature, and the best approach depends on how store admins use the backend.

In this guide, we'll implement a very simple blacklisting system that allows you to mark certain email addresses as blacklisted and require an admin to manually review and approve any orders placed with that email address.

To simplify the implementation, we'll assume the blacklisted email addresses are stored in an environment variable as a comma-separated string. Here are a couple of user stories we'll use as reference for the feature's requirement:

* Blacklisted orders are flagged automatically.
* Admins can manually approve blacklisted orders.

Without further ado, let's start writing some code!

## Adding new columns

The first step is to add the `blacklisted` column to the `spree_orders` table, which we'll use to determine whether an order has been blacklisted. This is quite simple to do with [a migration](https://guides.rubyonrails.org/active_record_migrations.html):

```bash
$ rails g migration AddBlacklistedToSpreeOrders blacklisted:boolean
$ rails db:migrate
```

This will add the `blacklisted` boolean column to `spree_orders`.

## Hooking into order events

The first step is to flag an order as blacklisted when the email address on the order has been blacklisted. You can do this by creating a class whose job is to analyze an order and determine whether it should be flagged as blacklisted:

{% code title="lib/awesome\_store/order\_analyzer.rb" %}
```ruby
module AwesomeStore
  class OrderAnalyzer
    def analyze(order)
      order.update!(blacklisted: )
    end

    private
    
    def blacklisted_emails
      ENV.fetch('BLACKLISTED_EMAILS', '').split(',')
    end

    def order_blacklisted?(order)
      order.email.in?(blacklisted_emails)
    end
  end
end
```
{% endcode %}

You will then need to subscribe to the `order_finalized` event, which is fired when an order is placed successfully, and call the analyzer:

{% code title="config/initializers/spree.rb" %}
```ruby
# ...
Spree::Event.subscribe 'order_finalized' do |payload|
  AwesomeStore::OrderAnalyzer.new.analyze(payload[:order])
end
```
{% endcode %}

Our new business logic is pretty easy to test in integration:

{% code title="spec/models/spree/order\_spec.rb" %}
```ruby
RSpec.describe Spree::Order do
  describe '#finalize!' do
    before do
      allow(ENV).to receive(:fetch)
        .with('BLACKLISTED_EMAILS', any_args)
        .and_return('jdoe@example.com')
      end
    end

    context 'when the email has been blacklisted' do
      it 'marks the order as blacklisted' do
        order = create(:order_ready_to_complete, email: 'jdoe@example.com')

        order.finalize!

        expect(order).to be_blacklisted
      end
    end

    context 'when the email has not been blacklisted' do
      it 'does not mark the order as blacklisted' do
        order = create(:order_ready_to_complete, email: 'hello@example.com')

        order.finalize!

        expect(order).not_to be_blacklisted
      end
    end
  end
end
```
{% endcode %}

At this point, we have a dead-simple order analyzer that determines whether each new order should be blacklisted or not. Now, we need to allow admins to manually review blacklisted orders and decide whether to reject them or remove them from the blacklist.

## Adding new actions

In order to allow admins to remove an order from the blacklist, we'll add a button to the order detail page that will trigger a new controller action.

{% hint style="info" %}
This section still needs to be written.
{% endhint %}

