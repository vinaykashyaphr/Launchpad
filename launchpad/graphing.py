import re
from io import StringIO

import pandas as pd
import plotly
import plotly.graph_objs as go


def group_events_by_time(incr, dataframe, zero_dates=False):
    dataframe.sort_values(['Date'], inplace=True)

    if zero_dates:
        dates_dataframe = pd.to_datetime(
            pd.date_range(
                dataframe['Date'].iloc[0],
                dataframe['Date'].iloc[-1]).to_frame()[0])
    else:
        dates_dataframe = pd.to_datetime(dataframe['Date'])

    if incr == 'days':
        return dates_dataframe.dt.strftime("%d/%m/%y").unique().tolist(),\
            "%d/%m/%y"
    if incr == 'weeks':
        return dates_dataframe.dt.strftime("Week %W").unique().tolist(),\
            "Week %W"
    if incr == 'months':
        return dates_dataframe.dt.strftime("%m/%Y").unique().tolist(), "%m/%Y"
    if incr == 'years':
        return dates_dataframe.dt.strftime("%Y").unique().tolist(), "%Y"


def get_single_event(df, format=None, date=None, user=None, event=None):
    df['Date'] = pd.to_datetime(df['Date'])

    if event is None:
        return df.loc[(df['Date'].dt.strftime(format) == date)
                      & (df['Username'] == user)].shape[0]
    elif user is None:
        return df.loc[(df['Date'].dt.strftime(format) == date)
                      & (df['Event'].str.contains(event))].shape[0]
    elif date is None:
        return df.loc[(df['Event'].str.contains(event))
                      & (df['Username'] == user)].shape[0]


def PlotGraph(csv_data, event, user, incr, total, title, zero_date):

    df = pd.read_csv(StringIO(csv_data))
    iter_users = user if user else df.Username.unique()
    iter_events = event if event is not None else df.Event.unique()
    single_user = len(iter_users) == 1

    data = []
    if not total:
        if single_user:
            for e in iter_events:
                e = re.sub(r'([)(])', r'\\\1', e)
                x_axis, format = group_events_by_time(incr, df, zero_dates=zero_date)
                # print(x_axis)
                data.append(
                    go.Bar(
                        x=x_axis,
                        y=[get_single_event(df, format, event=e, date=d)
                           for d in x_axis],
                        name=e))
        else:
            for u in iter_users:
                x_axis, format = group_events_by_time(incr, df)
                data.append(
                    go.Bar(
                        x=x_axis,
                        y=[get_single_event(df, format, user=u, date=d)
                           for d in x_axis],
                        name=u))
    elif total == 'user':
        for e in iter_events:
            e = re.sub(r'([)(])', r'\\\1', e)
            data.append(
                go.Bar(
                    x=iter_users,
                    y=[get_single_event(df, user=u, event=e)
                       for u in iter_users],
                    name=e))
    elif total == 'event':
        for u in iter_users:
            data.append(
                go.Bar(
                    x=iter_events,
                    y=[get_single_event(df, user=u, event=e)
                       for e in iter_events],
                    name=u))

    layout = go.Layout(
        barmode 		= 'stack' if not total else 'group',
        plot_bgcolor 	= 'rgb(227, 227, 227)',
        paper_bgcolor 	= 'rgb(227, 227, 227)',
        titlefont 		= dict(size=18 - title.count('<br>')),
        title = go.layout.Title(
            text		= title,
            xref		= 'paper',
            x			= 0.5
        ),
        font = dict(
            family 		= 'Montserrat, Courier New, monospace',
            size		= 12,
            color		= '#000000'
        ),
        xaxis=go.layout.XAxis(
            type='category',
            title=go.layout.xaxis.Title(
                text=('Time ({})'.format(incr)
                      if not total else total).title(),
                font=dict(size=16)
            )
        ),
        yaxis=go.layout.YAxis(
            title=go.layout.yaxis.Title(
                text='Occurrences',
                font=dict(size=16)
            )
        )
    )

    fig = go.Figure(data=data, layout=layout)
    return plotly.offline.plot(fig, output_type='div')
