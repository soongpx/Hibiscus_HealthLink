import firebase_admin
from firebase_admin import credentials, firestore
import pandas as pd
import plotly.express as px
import seaborn as sns
import streamlit as st
import matplotlib.pyplot as plt
import datetime

# ------------------------ Initialize Firebase ------------------------
fb_credentials = {}
fb_credentials = st.secrets["firebase"]['my_project_settings']

if not firebase_admin._apps:
    creds = credentials.Certificate(fb_credentials)
    firebase_admin.initialize_app(creds)
db = firestore.client()


# ------------------------ Fetch Data ------------------------
@st.cache_data
def fetch_health_data(user_id, collection_name):
    docs = db.collection('users').document(user_id).collection(collection_name).stream()
    data = []
    for doc in docs:
        entry = doc.to_dict()
        if isinstance(entry.get('date'), datetime.datetime):
            entry['date'] = entry['date']
        else:
            entry['date'] = None
        data.append(entry)
    df = pd.DataFrame(data)
    df = df.dropna(subset=['date', 'value'])
    df['date'] = pd.to_datetime(df['date'], errors='coerce')
    return df.sort_values('date')


# ------------------------ Plot Interactive Graph ------------------------
def plot_interactive_graph(df, metric_name, y_label, color):
    if df.empty:
        st.warning(f"No data available for {metric_name}.")
        return

    # Group by date and calculate the daily average
    df_daily_avg = df.groupby(df['date'].dt.date)['value'].mean().reset_index()
    df_daily_avg['date'] = pd.to_datetime(df_daily_avg['date'])

    # Interactive Plotly line chart
    fig = px.line(
        df_daily_avg, x='date', y='value',
        title=f"{metric_name} (Daily Average)",
        labels={'date': 'Date', 'value': y_label},
        color_discrete_sequence=[color]
    )

    # Add markers and customize layout
    fig.update_traces(mode='lines+markers')
    fig.update_layout(hovermode='x unified', template='plotly_dark', height=350)

    st.plotly_chart(fig, use_container_width=True)


# ------------------------ Plot Daily Average ------------------------
def plot_daily_average(df, metric_name, y_label, color):
    if df.empty:
        st.warning(f"No data available for {metric_name}.")
        return

    # Group by date and calculate daily average
    df_daily_avg = df.groupby(df['date'].dt.date)['value'].mean().reset_index()
    df_daily_avg['date'] = pd.to_datetime(df_daily_avg['date'])

    # Plotly interactive plot
    fig = px.line(
        df_daily_avg, x='date', y='value',
        title=f"{metric_name} - Daily Average",
        labels={'date': 'Date', 'value': y_label},
        color_discrete_sequence=[color]
    )
    fig.update_traces(mode='lines+markers')
    fig.update_layout(hovermode='x unified', template='plotly_dark', height=400)
    st.plotly_chart(fig, use_container_width=True)


# ------------------------ Plot Rolling Average ------------------------
def plot_rolling_avg(df, metric_name, y_label, color):
    if df.empty:
        st.warning(f"No data available for {metric_name}.")
        return

    # Calculate 7-day rolling average
    df['7-Day Rolling Avg'] = df['value'].rolling(window=7).mean()

    # Plotly interactive plot
    fig = px.line(
        df, x='date', y=['value', '7-Day Rolling Avg'],
        title=f"{metric_name} - Rolling Average",
        labels={'date': 'Date', 'value': y_label, '7-Day Rolling Avg': '7-Day Rolling Avg'},
        color_discrete_sequence=[color, 'orange']
    )
    fig.update_traces(mode='lines+markers')
    fig.update_layout(hovermode='x unified', template='plotly_dark', height=400)
    st.plotly_chart(fig, use_container_width=True)


# ------------------------ Plot Distribution ------------------------
def plot_distribution(df, metric_name, color):
    if df.empty:
        st.warning(f"No data available for {metric_name}.")
        return

    plt.figure(figsize=(8, 4))
    sns.histplot(df['value'], bins=30, kde=True, color=color)
    plt.title(f'Distribution of {metric_name}')
    plt.xlabel('Value')
    plt.ylabel('Frequency')
    st.pyplot(plt)


# ------------------------ Descriptive Statistics ------------------------
def show_descriptive_statistics(df, metric_name):
    if df.empty:
        st.warning(f"No data available for {metric_name}.")
        return

    st.write(f"### Descriptive Statistics for {metric_name}")
    st.dataframe(df['value'].describe())


# ------------------------ Main Dashboard ------------------------
def main():
    st.set_page_config(page_title="Healthcare Data Dashboard", layout="wide")
    st.title("📊 Healthcare Data Analytics Dashboard")

    # Sidebar for User Details
    st.sidebar.header("Patient Information")
    user_id = "XGvNdZVjWvMpckDP0Dp7jT6Ocdv1"
    user_name = st.sidebar.text_input("Patient Name:", "Soong Peng Xiang")
    user_ic = st.sidebar.text_input("Patient IC Number:", "121110-05-9101")
    date_range = st.sidebar.date_input("Select Date Range",
                                       [datetime.date.today() - datetime.timedelta(days=30), datetime.date.today()])

    st.sidebar.markdown("---")
    st.sidebar.info("Use the controls to fetch and analyze patient health data.")

    # Fetch data button
    if st.sidebar.button("Fetch and Analyze Data"):
        with st.spinner("Fetching data..."):
            df_hr = fetch_health_data(user_id, 'heartRates')
            df_sp = fetch_health_data(user_id, 'spO2Levels')
            df_gl = fetch_health_data(user_id, 'GlucoseLevels')
            df_ch = fetch_health_data(user_id, 'CholesterolLevels')

        # Filter data based on date range
        start_date, end_date = date_range
        dfs = {
            "Heart Rate": df_hr,
            "SpO2 Levels": df_sp,
            "Glucose Levels": df_gl,
            "Cholesterol Levels": df_ch
        }
        start_date = pd.to_datetime(start_date, utc=True)
        end_date = pd.to_datetime(end_date, utc=True)

        for metric_name, df in dfs.items():
            # Drop rows with NaT in the 'date' column before filtering
            df['date'] = pd.to_datetime(df['date'], errors='coerce')
            df = df.dropna(subset=['date'])
            df = df[(df['date'] >= pd.to_datetime(start_date)) & (df['date'] <= pd.to_datetime(end_date))]
            dfs[metric_name] = df

        # Dashboard Layout
        st.markdown(f"### Health Metrics for {user_name}")
        st.write(f"**IC Number:** {user_ic}")

        # Display graphs in a 2x2 grid
        col1, col2 = st.columns(2)

        with col1:
            st.subheader("Heart Rate (bpm)")
            plot_interactive_graph(dfs["Heart Rate"], "Heart Rate", "BPM", "red")

        with col2:
            st.subheader("SpO2 Levels (%)")
            plot_interactive_graph(dfs["SpO2 Levels"], "SpO2 Levels", "%", "blue")

        with col1:
            st.subheader("Glucose Levels (mg/dL)")
            plot_interactive_graph(dfs["Glucose Levels"], "Glucose Levels", "mg/dL", "green")

        with col2:
            st.subheader("Cholesterol Levels (mg/dL)")
            plot_interactive_graph(dfs["Cholesterol Levels"], "Cholesterol Levels", "mg/dL", "purple")

        # Summary Table
        st.markdown("### Summary Table")
        summary_data = {
            "Metric": ["Heart Rate", "SpO2 Levels", "Glucose Levels", "Cholesterol Levels"],
            "Average": [
                dfs["Heart Rate"]['value'].mean() if not dfs["Heart Rate"].empty else "No Data",
                dfs["SpO2 Levels"]['value'].mean() if not dfs["SpO2 Levels"].empty else "No Data",
                dfs["Glucose Levels"]['value'].mean() if not dfs["Glucose Levels"].empty else "No Data",
                dfs["Cholesterol Levels"]['value'].mean() if not dfs["Cholesterol Levels"].empty else "No Data",
            ]
        }
        summary_df = pd.DataFrame(summary_data)
        st.dataframe(summary_df)

        tabs = st.tabs(["Heart Rate", "SpO2 Levels", "Glucose Levels", "Cholesterol Levels"])

        for tab, (metric_name, df, color, y_label) in zip(
                tabs,
                [("Heart Rate", dfs["Heart Rate"], "red", "BPM"),
                 ("SpO2 Levels", dfs["SpO2 Levels"], "blue", "%"),
                 ("Glucose Levels", dfs["Glucose Levels"], "green", "mg/dL"),
                 ("Cholesterol Levels", dfs["Cholesterol Levels"], "purple", "mg/dL")]):
            with tab:
                st.subheader(f"{metric_name}")

                # Daily Average Graph
                st.write("### Daily Average")
                plot_daily_average(df, metric_name, y_label, color)

                # Rolling Average Graph
                st.write("### Rolling Average")
                plot_rolling_avg(df, metric_name, y_label, color)

                # Data Table
                st.write("### Data Table")
                st.dataframe(df)

                # Descriptive Statistics
                show_descriptive_statistics(df, metric_name)

                # Distribution Plot
                st.write("### Distribution")
                plot_distribution(df, metric_name, color)


if __name__ == "__main__":
    main()
