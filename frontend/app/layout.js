import "./globals.css";

export const metadata = {
  title: "CarbonTrace | Supply Chain Decarbonization",
  description: "Supplier, shipment, and product emissions intelligence with accountable reduction initiatives."
};

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
