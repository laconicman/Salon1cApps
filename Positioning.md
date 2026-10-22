# What these apps are for

Draft prose for the App Store descriptions, the README's opening, and anything else that has
to explain the apps to someone in one breath. Derived from what the 1С:SPA-Салон API makes
possible (62 operations, read from the vendor's OpenAPI document — the `Salon1cAPI` package
is the audit trail) and from what the interface has to do about it. Nothing here is a
promise the API cannot keep; where the API's behaviour is still only *documented* rather
than *observed*, it says so.

Two apps, one direction. The direction is an **aggregator** — one app where a person books
at any salon that runs this software. The first release is **white-label** — one salon's
own app, configured rather than programmed. The reasons for that order are in the API, and
they are given below rather than assumed.

---

## The short version

**A salon already runs its whole business in 1С. These apps put that business in the hands
of the people it is for — the customer, and the person behind the chair.**

1С:Салон красоты is the back office: the schedule, the masters, the price list, every
client's history, loyalty balance, packages, certificates, the online store. Its API
exposes nearly all of it — booking with the salon's real availability, confirmation by SMS,
WhatsApp, call or Telegram, visit history, accounts and top-ups, packages with their frozen
and guest visits, ratings, a shop with delivery and payment, sales and payment links, a
master's work schedule. It was written so that a salon's own app or site could use it.

And then a salon that is three chairs and a reception desk has an API and nobody to call it.
Its customers book by phone and messenger, and what the salon knows about them stays on the
reception computer.

That is the gap. Not another booking marketplace that asks the salon to move its business
into someone else's system, but a window onto the system it already runs.

---

## Two apps

**For the customer** — *the salon's own app.* Book a service with a chosen master at a time
the salon can actually give; reschedule or cancel; see what is coming up and what has been;
confirm by the channel the salon already uses. See the loyalty balance and its statement,
the packages and how many visits are left (including frozen ones), the certificates. Rate the
visit. Buy from the salon's shop if it has one. Nothing a receptionist would have to type in
again: every one of those is an API operation, so the app is the record, not a copy of it.

**For the staff** — *the salon's day, on a phone.* Who is coming today and when. Find a
client by phone, or create one at the chair. Take a sale, send a payment link, settle a visit
that is owed. See and edit a master's schedule. 1С's own client lives on the reception
computer; the person doing the work does not sit there.

The two share one package and one understanding of the salon, and they are honest about
the seam between them: the customer app carries the salon's API key because *every* call
needs it — that is the vendor's model for any client-side app, not ours — and the staff app
carries it because the staff are the salon.

---

## Three things they do that the alternatives don't

**The whole customer record, not just the booking.** Marketplaces show slots. The salon's
system knows the balance, the package, the certificate, the history, the rating you left —
and the API returns all of it. A customer who sees "7 visits left, 2 frozen" is seeing the
salon's own ledger, live.

**Booking that obeys the salon's real rules.** Services, then masters who do them, then
dates, then slots — as the salon's system computes them, with the cost calculated before
confirming and the salon's own confirmation code. No parallel calendar that someone has to
reconcile on Monday.

**No second system.** The salon keeps one source of truth. Nothing is migrated, nothing is
synchronised, nothing is owed to a platform. The apps read and write the system the salon
already pays for; if the apps disappear tomorrow, the salon has lost a window, not its data.

---

## Why white-label first, and what the aggregator actually requires

The API is scoped to one deployment: an API key belongs to one salon or chain, and "list
the salons" returns that chain's branches, not the city's. There is no cross-salon
discovery, and no neutral way to call a salon without its key. So:

- A **white-label** app needs no server. One salon, one key, one configuration; the phone
  talks to the salon's 1С directly. It can ship first and prove the client against the
  wire — which has not happened yet: every shape in the package is documented behaviour,
  not observed (the package's `TD-1`).
- An **aggregator** needs a server from day one, and not for features — for custody. Many
  salons' keys cannot be shipped inside one public binary; a key that leaks opens that
  salon's client list. The server holds the keys, routes by salon, and — the one thing
  nobody else can do for us — turns *new booking* into a push to the staff app, because
  the API has no webhooks; everything is poll and compare.

Building white-label first with the salon as a *configuration* rather than a constant is
what makes the second step a change of where the configuration comes from, not a rewrite.

---

## Who it is for

**The small salon on 1С.** You have the software because your accountant and your stock
needed it. Your clients book by messaging you. You are not going to commission an app.

**The chain that already has the vendor's branded app, or priced one.** You want the same
on your terms: your branding, your release schedule, no per-feature negotiation.

**The master who is not at the desk.** The schedule is on the reception computer; your next
client is a question you ask out loud. You need today, your clients, and a way to take
payment — on the thing in your pocket.

*Later, honestly labelled:* the person who goes to three salons and would like one app and
one phone number for all of them. That is the aggregator, and it waits for the server.

---

## What they are not

They are **unofficial**. Not made by, endorsed by, or affiliated with 1С or the vendor of
1С:Салон красоты. They carry none of the vendor's branding, and they do not resell the
software or the salon's services: the salon brings its own installation and its own API key,
and the apps talk to it on the salon's behalf.

The customer app is **not a marketplace** (yet, and never without saying so). It is one
salon's app; the salon chose it.

In the white-label release **nothing leaves the phone except the call to the salon's own
system**: no account with us, no analytics, no server. When the aggregator arrives, that
sentence changes, and it has to be rewritten here first.

**Reminders are local.** The app knows when the visit is because it booked it; the salon's
own SMS reminder exists too. A push that arrives because something changed *at the salon*
is the server's job, and the server is later.

---

## Lines that can be lifted directly

Short, for the App Store subtitle or a README first line (store copy is Russian; the
English gloss is for this document):

- *Запись, визиты, баланс и пакеты — ваш салон в телефоне.* — Booking, visits, balance and
  packages — your salon on your phone.
- *Приложение салона, который уже работает в 1С.* — The app for a salon that already runs
  on 1С.
- *Сегодняшние визиты, клиенты и оплата — для тех, кто за креслом.* — Today's visits,
  clients and payment — for the person behind the chair. (staff)

One paragraph, for a store description's opening (customer app):

> Записывайтесь к своему мастеру на то время, которое салон действительно может дать,
> переносите и отменяйте визиты, подтверждайте номер так, как привыкли — по СМС, в
> WhatsApp или звонком. Видите баланс и его историю, пакеты услуг и сколько посещений
> осталось, сертификаты, прошлые визиты. Это не ещё одна площадка: приложение показывает
> систему, в которой салон ведёт дела, — и ничего не дублирует.

For the "why this exists" note, if a README wants one:

> The salon's software has an API written for a salon with developers. Most salons that run
> it have a reception desk and a phone. These are the apps the API was waiting for.

---

## Still to verify before any of this is printed

- **The vendor's own branded client app** — whether it exists for sale, what it includes,
  what it costs. Read from the vendor's site, which is unreachable from the development
  machine; it decides whether "the chain that priced one" is a real audience.
- **Whether a customer's token can call the staff-side operations.** The vendor declares a
  user token on sales, client search and schedule editing; which *person's* token the server
  accepts there is not written down. The staff app's auth design hangs on it (the API also
  offers signature-based authorization for trusted integrations, which may be the intended
  path). A live call settles it; nothing else does.
- **Every wire shape** — the package has 27 declared corrections to the vendor's document
  and six envelope dialects, all pinned by tests against documented examples and the
  vendor's mock, none against a real salon. The first live credential is the first real
  review of this document.

---

## A note on tone, for whoever writes the rest

Two failure modes. The first is marketplace cheerfulness — this is a salon's own app, and
its customers are regulars, not shoppers; it should feel like the salon, not like us. The
second is API vocabulary: *record*, *user token*, *parameters*, *deposit*, *ticket* are the
vendor's words and none of them should reach the interface or the store page. Say visit,
booking, master, service, balance, package, certificate.
