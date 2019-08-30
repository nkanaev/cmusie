#!/usr/bin/env python3
import os
import asyncio
import pyppeteer


def path(filename):
    return os.path.join(os.path.dirname(os.path.abspath(__file__)), filename)


async def svg2png(infile, outfile, size=512, padding=0.1, color='#333333'):
    browser = await pyppeteer.launch()
    page = await browser.newPage()
    await page.setViewport({'width': size, 'height': size})
    await page.goto('file://' + infile)
    await page.evaluate('''() => {{
        var svg = document.querySelector('svg')
        svg.style.color = '{color}'
        svg.style.padding = '{padding}'
        svg.style.boxSizing = 'border-box'
        svg.style.height = '100vh'
        svg.style.width = '100%'
    }}'''.format(color=color, padding=padding * size))
    await page.screenshot({
        'path': outfile,
        'omitBackground': True,
    })
    await browser.close()


async def main():
    size = 16
    for icon in ['unlock', 'power-off', 'play', 'pause', 'backward', 'forward']:
        svgpath = path(icon + '-solid.svg')
        await svg2png(svgpath, f'{icon}-{size}.png', size=size)
        await svg2png(svgpath, f'{icon}-{size}@2x.png', size=size * 2)


if __name__ == '__main__':
    asyncio.get_event_loop().run_until_complete(main())
