# Family Planner

Ιδιωτικό οικογενειακό ημερολόγιο για δραστηριότητες παιδιών και to-do.

## Αρχιτεκτονική

- **GitHub Pages:** μόνο HTML/CSS/JavaScript (δημόσιος κώδικας).
- **Supabase Auth:** εγγραφή και σύνδεση με email/password.
- **Supabase PostgreSQL:** δραστηριότητες, παιδιά, μέλη οικογένειας.
- **Row Level Security (RLS):** μόνο μέλη της συγκεκριμένης οικογένειας διαβάζουν και αλλάζουν δεδομένα.

**ΠΡΟΣΟΧΗ:** Τα δεδομένα δεν αποθηκεύονται στο GitHub. Μην γράψεις πραγματικά δεδομένα στο README, σε issues ή σε commits. Μην ανεβάσεις ποτέ Supabase `service_role`, `secret` keys ή κωδικό βάσης. Το public/publishable key επιτρέπεται στο frontend, υπό την προϋπόθεση σωστού RLS.

## 1. Δημιουργία Supabase

1. Άνοιξε https://supabase.com και δημιούργησε ένα **νέο project**.
2. Από το **SQL Editor**, εκτέλεσε ολόκληρο το [schema.sql](./schema.sql) σε αυτό το νέο project. Το SQL δημιουργεί πίνακες, access policies και RPC functions.
3. Από το project, βρες το **Project URL** και το **publishable key** (ή το παλιό anon key).
4. Ενημέρωσε το [config.js](./config.js):
   ```js
   window.FAMILY_PLANNER_CONFIG = {
     supabaseUrl: "https://YOUR_PROJECT.supabase.co",
     supabasePublishableKey: "sb_publishable_YOUR_KEY"
   };
   ```
5. Στο Supabase Authentication → URL Configuration, όρισε:
   - **Site URL:** `https://michalis-dev.github.io/family-planner/`
   - **Redirect URLs:** πρόσθεσε την ίδια διεύθυνση.
6. Στο Authentication → Providers → Email, ενεργοποίησε την επιβεβαίωση email. Για ιδιωτική οικογενειακή χρήση συνιστάται να απενεργοποιήσεις την ανοικτή εγγραφή αφότου δημιουργηθούν οι λογαριασμοί που χρειάζεστε.

## 2. GitHub Pages

Στο repo → **Settings → Pages → Build and deployment → Deploy from a branch**.

Διάλεξε `main` και `/(root)` → Save.

Η αναμενόμενη διεύθυνση είναι: https://michalis-dev.github.io/family-planner/

Η σύνδεση δεν λειτουργεί μέχρι να ολοκληρωθεί η ρύθμιση Supabase. Η εφαρμογή δεν εμφανίζει πραγματικά στοιχεία όταν λείπει το config.

## 3. Κοινή χρήση

1. Ο πρώτος χρήστης εγγράφεται και δημιουργεί οικογένεια.
2. Αντιγράφει τον **κωδικό πρόσκλησης** που εμφανίζεται στο ημερολόγιο.
3. Ο δεύτερος χρήστης δημιουργεί δικό του λογαριασμό και επιλέγει **Συμμετοχή**.
4. Μόνο οι χρήστες που ανήκουν στην οικογένεια μπορούν να διαβάσουν και να αλλάξουν τις δραστηριότητές της.

Οι αλλαγές ενημερώνονται κατά το άνοιγμα/ανανέωση και περιοδικά περίπου ανά 30 δευτερόλεπτα. Δεν υλοποιείται ακόμη push notification ή πλήρης real-time μετάδοση.

## 4. Έλεγχοι ασφάλειας πριν από πραγματική χρήση

- Επιβεβαίωσε το RLS στο Supabase: όλοι οι τέσσερις πίνακες πρέπει να έχουν **RLS enabled**.
- Κάνε δοκιμή με τρίτο λογαριασμό χωρίς πρόσκληση: δεν πρέπει να διαβάζει οικογενειακά δεδομένα.
- Κάνε δοκιμή με δύο λογαριασμούς της ίδιας οικογένειας.
- Αντιμετώπισε τον κωδικό πρόσκλησης σαν μυστικό και μην τον δημοσιεύεις.
- Βεβαιώσου ότι έχεις σωστές ρυθμίσεις authentication, backup και προστασίας των λογαριασμών.
- Μην προσθέτεις ονόματα, ιατρικά στοιχεία ή άλλες ευαίσθητες πληροφορίες για παιδιά πριν ολοκληρωθούν οι έλεγχοι.

## Περιεχόμενα

- `index.html`: εφαρμογή (responsive interface)
- `config.js`: δημόσια στοιχεία σύνδεσης Supabase, αρχικά κενά
- `schema.sql`: PostgreSQL πίνακες, RPC και Row Level Security
- `manifest.webmanifest`: εγκατάσταση ως web app
- `.gitignore`: προστασία τοπικών env files

Κατασκευασμένο ώστε να φιλοξενείται ως static website χωρίς μόνιμο δικό σου server.
