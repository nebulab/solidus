# Creating your storefront

## Solidus and "themes"

The first aspect you'll want to customize in your store is the storefront. Unlike other platforms such as Shopify and Magento, Solidus doesn't have the concept of "themes." In other words, it's not possible to download and install a pre-made storefront. Instead, you'll have to build your own from scratch.

This is by design: for the kind of stores Solidus was built for, pre-made themes are not really an option, because they don't allow you to create a unique shopping experience.

While developing a shopping experience from scratch may feel intimidating at first, it's an approach that allows unmatched freedom and flexibility. Also, Solidus also provides some powerful tools you can use to accelerate the development of your storefront.

## Laying the foundations

{% hint style="info" %}
We are currently working on a complete revamp of the stock Solidus storefront. It's called [`solidus_starter_frontend`](https://github.com/nebulab/solidus_starter_frontend) and it's much more modern and component-oriented. It's still being actively developed, but you may want to check it out if you're just starting a new store and want a better foundation to start from.
{% endhint %}

The [`solidus_frontend`](https://github.com/solidusio/solidus/tree/master/frontend) is a Rails engine that provides a set of assets, controllers, helpers and views you can use as the starting point for your own storefront. In general, all rules of Rails engines also stand for Solidus: if you want to override a view or an asset, simply create a file in the same path in your own application, and Rails will use your implementation instead of the Solidus version.

You can run this command to copy all the views from the default frontend into your app:

```bash
$ rails g solidus:views:override
```

This will copy all the views into your own application, so that they can be easily modified. Feel free to browse around the new files and get a sense of how everything works.

In the rest of this guide, we'll build our own dead-simple storefront.

## Customizing the layout

{% hint style="info" %}
This section is still being written.
{% endhint %}

## Adding static pages

{% hint style="info" %}
This section is still being written.
{% endhint %}

