import "./globals.css";
import Link from "next/link";

export default function RootLayout({
                                       children,
                                   }: {
    children: React.ReactNode;
}) {
    return (
        <html lang="en">
        <body className="bg-gray-100 text-gray-900">
        <nav className="bg-black text-white px-6 py-4 flex gap-6">
            <Link href="/">Dashboard</Link>
            <Link href="/create">Create Dispute</Link>
            <Link href="/disputes">Disputes</Link>
            <Link href="/health">DB Health</Link>
        </nav>

        <main className="p-6">{children}</main>
        </body>
        </html>
    );
}